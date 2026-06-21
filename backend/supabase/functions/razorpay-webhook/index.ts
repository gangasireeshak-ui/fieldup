// Edge Function: razorpay-webhook
// Verifies Razorpay HMAC signature and confirms bookings after payment.captured event.
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts";

const RAZORPAY_WEBHOOK_SECRET  = Deno.env.get("RAZORPAY_WEBHOOK_SECRET")!;
const SUPABASE_URL              = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY      = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  const body = await req.text();
  const signature = req.headers.get("x-razorpay-signature");

  if (!signature) {
    return new Response("Missing signature", { status: 400 });
  }

  // Verify HMAC-SHA256
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw", encoder.encode(RAZORPAY_WEBHOOK_SECRET),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const signatureBuffer = await crypto.subtle.sign("HMAC", key, encoder.encode(body));
  const expectedSignature = Array.from(new Uint8Array(signatureBuffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  if (expectedSignature !== signature) {
    return new Response("Invalid signature", { status: 400 });
  }

  const event = JSON.parse(body);
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  if (event.event === "payment.captured") {
    const payment = event.payload.payment.entity;
    const orderId = payment.order_id;
    const paymentId = payment.id;

    // Confirm booking associated with this order
    const { error } = await supabase
      .from("bookings")
      .update({ status: "confirmed", razorpay_payment_id: paymentId })
      .eq("razorpay_order_id", orderId)
      .eq("status", "pending");

    if (error) {
      console.error("Failed to confirm booking:", error);
      return new Response("DB error", { status: 500 });
    }

    // Award karma points (5 per booking)
    const { data: booking } = await supabase
      .from("bookings")
      .select("user_id, id")
      .eq("razorpay_order_id", orderId)
      .single();

    if (booking) {
      await supabase.rpc("add_karma", {
        p_user_id: booking.user_id,
        p_points: 5,
        p_action: "booking",
        p_ref_id: booking.id,
        p_desc: "Venue booking reward",
      });
    }
  }

  if (event.event === "payment.failed") {
    const orderId = event.payload.payment.entity.order_id;
    await supabase
      .from("bookings")
      .update({ status: "cancelled" })
      .eq("razorpay_order_id", orderId)
      .eq("status", "pending");
  }

  return new Response("ok", { status: 200 });
});
