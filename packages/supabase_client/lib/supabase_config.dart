/// Supabase project constants.
/// Credentials are injected at build time via --dart-define.
/// Never hardcode the service_role key in Flutter.
library;

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://nweibhcjqnumxcpwnrvo.supabase.co',
);

const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53ZWliaGNqcW51bXhjcHducnZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwMjAzNjIsImV4cCI6MjA5NzU5NjM2Mn0.O4LNQOY2Ub69KcKnGBqbsFG2D6NkB8wdEfmIPqYJEgo',
);
