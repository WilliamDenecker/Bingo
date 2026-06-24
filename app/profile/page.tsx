import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { BottomNav } from "@/components/BottomNav";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SignOutButton } from "@/app/profile/SignOutButton";
import { AvatarUpload } from "@/app/profile/AvatarUpload";

interface ProfileRow {
  display_name: string;
  created_at: string;
  avatar_url: string | null;
}

export default async function ProfilePage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profileRaw } = await supabase
    .from("profiles")
    .select("display_name, created_at, avatar_url")
    .eq("id", user.id)
    .single();
  const profile = profileRaw as unknown as ProfileRow | null;

  return (
    <div className="min-h-screen pb-20">
      <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur">
        <div className="flex h-14 items-center px-4 max-w-md mx-auto">
          <h1 className="font-semibold text-lg">Profile</h1>
        </div>
      </header>

      <main className="px-4 py-6 max-w-md mx-auto space-y-4">
        <AvatarUpload
          displayName={profile?.display_name ?? "?"}
          avatarUrl={profile?.avatar_url ?? null}
        />
        <div className="text-center -mt-2">
          <h2 className="text-xl font-semibold">{profile?.display_name}</h2>
          <p className="text-sm text-muted-foreground">
            Joined{" "}
            {profile?.created_at
              ? new Date(profile.created_at).toLocaleDateString()
              : "—"}
          </p>
          <p className="text-xs text-muted-foreground mt-1">Tap your avatar to change it</p>
        </div>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Account</CardTitle>
          </CardHeader>
          <CardContent>
            <SignOutButton />
          </CardContent>
        </Card>

        <p className="text-xs text-center text-muted-foreground pt-4">
          Made by Vettebokbeer
        </p>
      </main>

      <BottomNav />
    </div>
  );
}
