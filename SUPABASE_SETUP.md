# Supabase Setup Guide

## Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click "New Project"
4. Fill in project details:
   - **Name**: furniture-billing-backup (or your preferred name)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to your location
5. Click "Create new project" and wait for setup to complete

## Step 2: Run Migration Script

1. In your Supabase project dashboard, go to **SQL Editor**
2. Click "New query"
3. Copy the entire contents of `supabase_migration.sql`
4. Paste into the SQL editor
5. Click "Run" to execute the migration
6. Verify all tables are created in **Table Editor**

## Step 3: Get API Credentials

1. Go to **Project Settings** → **API**
2. Copy the following values:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...` (long string)
3. Save these credentials securely

## Step 4: Configure Flutter App

1. Create a `.env` file in the project root (if not exists):

```env
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```

2. Add `.env` to `.gitignore` to keep credentials secure:

```gitignore
.env
```

3. The app will use these credentials to connect to Supabase

## Step 5: Verify Connection

After implementing the backup service, you can test the connection:

1. Run the app
2. Go to Settings → Backup
3. Click "Test Connection" (will be implemented)
4. Should show "Connected successfully"

## Security Notes

> [!IMPORTANT]
> - Never commit your Supabase credentials to version control
> - Use environment variables or secure storage for production
> - The current RLS policies allow all authenticated users - adjust based on your needs

## Optional: Disable RLS for Testing

If you want to disable Row Level Security during development:

```sql
ALTER TABLE bills DISABLE ROW LEVEL SECURITY;
ALTER TABLE bill_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE backup_logs DISABLE ROW LEVEL SECURITY;
```

**Remember to re-enable RLS before production!**

## Troubleshooting

### Connection Issues
- Verify your project URL and anon key are correct
- Check if your IP is allowed (Supabase allows all by default)
- Ensure your internet connection is stable

### Migration Errors
- Check SQL syntax in the error message
- Ensure you're running the script in the correct order
- Try running sections individually if needed

### RLS Policy Issues
- Temporarily disable RLS for testing
- Check authentication status
- Review policy conditions

## Next Steps

Once setup is complete:
1. ✅ Database tables created
2. ✅ Credentials configured
3. → Implement backup service in Flutter
4. → Test automatic and manual backups
