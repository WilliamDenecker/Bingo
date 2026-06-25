import pg from "pg";
import { readFileSync } from "fs";
import { config } from "dotenv";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
config({ path: resolve(__dirname, "../.env.local") });

const connectionString = process.env.SUPABASE_DB_URL;

if (!connectionString) {
  console.error(
    "❌ Missing SUPABASE_DB_URL in .env.local\n" +
    "   Get it from: Supabase dashboard → Settings → Database → Connection string → URI\n" +
    "   Use the 'Session mode' connection string (port 5432)"
  );
  process.exit(1);
}

const client = new pg.Client({ connectionString, ssl: { rejectUnauthorized: false } });

const migrations = [
  "../supabase/migrations/001_schema.sql",
  "../supabase/migrations/002_rls.sql",
  "../supabase/migrations/003_seed.sql",
  "../supabase/migrations/004_seed_users.sql",
  "../supabase/migrations/005_avatar.sql",
  "../supabase/migrations/006_proof.sql",
];

async function run() {
  await client.connect();
  console.log("✅ Connected to database\n");

  // Full reset — drop everything so migrations run clean
  console.log("🗑️  Resetting existing data...");
  await client.query(`
    -- Drop RLS policies
    drop policy if exists "profiles_select"          on profiles;
    drop policy if exists "profiles_update_own"      on profiles;
    drop policy if exists "bingo_squares_select"     on bingo_squares;
    drop policy if exists "user_squares_select"      on user_squares;
    drop policy if exists "user_squares_insert_own"  on user_squares;
    drop policy if exists "user_squares_update_own"  on user_squares;

    -- Drop storage policies
    drop policy if exists "avatars_insert_own"    on storage.objects;
    drop policy if exists "avatars_update_own"    on storage.objects;
    drop policy if exists "avatars_delete_own"    on storage.objects;
    drop policy if exists "avatars_select_public" on storage.objects;
    drop policy if exists "proofs_insert_own"     on storage.objects;
    drop policy if exists "proofs_update_own"     on storage.objects;
    drop policy if exists "proofs_delete_own"     on storage.objects;
    drop policy if exists "proofs_select_public"  on storage.objects;

    -- Drop triggers and functions
    drop trigger if exists on_auth_user_created on auth.users;
    drop trigger if exists on_profile_created   on profiles;
    drop function if exists handle_new_user();
    drop function if exists initialize_user_squares();

    -- Drop helper functions
    drop function if exists insert_grid(uuid, text[]);

    -- Drop tables (order matters for foreign keys)
    drop table if exists user_squares;
    drop table if exists bingo_squares;
    drop table if exists profiles;

    -- Clear auth users
    delete from auth.users where email like '%@bingo.local';
  `).catch((err) => { console.warn("  (reset warning:", err.message, ")"); });
  console.log("✅ Reset complete\n");

  for (const file of migrations) {
    const filePath = resolve(__dirname, file);
    const sql = readFileSync(filePath, "utf8");
    const name = file.split("/").pop();

    process.stdout.write(`⏳ Running ${name}...`);
    try {
      await client.query(sql);
      console.log(" ✅");
    } catch (err) {
      console.error(`\n❌ Failed on ${name}:\n${err.message}`);
      await client.end();
      process.exit(1);
    }
  }

  await client.end();
  console.log("\n🎉 All migrations complete! App is ready.");
}

run();
