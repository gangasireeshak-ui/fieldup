import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

// ─── Dynamic Pricing Engine ───────────────────────────────────────────────────

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});
  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _prices = <String, double>{
    'Morning (6–10 AM)': 400,
    'Peak (10 AM–4 PM)': 600,
    'Evening (4–8 PM)': 800,
    'Night (8 PM–11 PM)': 500,
  };
  bool _dynamicEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DYNAMIC PRICING ENGINE', style: _head(28, c: _kBlue)),
            const SizedBox(height: 4),
            Text('Set smart pricing based on demand & time', style: _body(13)),
            const SizedBox(height: 20),

            // Dynamic pricing toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _dynamicEnabled ? _kLime.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _dynamicEnabled ? _kLime.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('AI DYNAMIC PRICING', style: _head(16, c: _dynamicEnabled ? _kLime : Colors.white)),
                  Text('Auto-adjusts based on demand', style: _body(11)),
                ]),
                const Spacer(),
                Switch(
                  value: _dynamicEnabled,
                  activeColor: _kLime,
                  onChanged: (v) => setState(() => _dynamicEnabled = v),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            Text('TIME-SLOT PRICING', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),

            ..._prices.entries.map((e) => _PriceSlider(
              label: e.key,
              value: e.value,
              onChanged: (v) {
                HapticFeedback.lightImpact();
                setState(() => _prices[e.key] = v);
              },
            )),

            const SizedBox(height: 20),
            Text('WEEKEND SURGE', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(children: [
                Text('Surge Multiplier', style: _body(13, c: Colors.white)),
                const Spacer(),
                Text('1.5×', style: _head(20, c: _kBlue)),
              ]),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _kBlue.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Text('SAVE PRICING RULES →', style: _head(16, c: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PriceSlider extends StatelessWidget {
  const _PriceSlider({required this.label, required this.value, required this.onChanged});
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Column(children: [
      Row(children: [
        Text(label, style: _body(12, c: Colors.white.withValues(alpha: 0.7))),
        const Spacer(),
        Text('₹${value.round()}/hr', style: _head(18, c: _kBlue)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: _kBlue,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
          thumbColor: _kBlue,
          overlayColor: _kBlue.withValues(alpha: 0.15),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        child: Slider(value: value, min: 200, max: 2000, divisions: 36, onChanged: onChanged),
      ),
    ]),
  );
}
