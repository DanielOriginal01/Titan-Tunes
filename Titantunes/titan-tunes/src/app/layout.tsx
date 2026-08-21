import "./globals.css";
import type { Metadata } from "next";
import { GoogleOAuthProvider } from "@react-oauth/google";
import { AuthProvider } from "@/providers/AuthProvider";
import { ThemeProvider } from "@/components/shared/ThemeProvider";
import { AudioPlayerProvider } from "@/providers/AudioPlayerProvider";
import { FloatingAudioPlayer } from "@/components/shared/FloatingAudioPlayer";

export const metadata: Metadata = {
  title: "Titan Tunes",
  description: "Plateforme web de streaming musical pour artistes et auditeurs.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <body className="transition-colors duration-300">
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var t=localStorage.getItem('titan_theme');if(t==='dark'){document.documentElement.classList.add('dark');document.documentElement.style.colorScheme='dark';document.documentElement.dataset.theme='dark';}else if(t==='light'){document.documentElement.classList.remove('dark');document.documentElement.style.colorScheme='light';document.documentElement.dataset.theme='light';}else{var m=window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;if(m){document.documentElement.classList.add('dark');document.documentElement.style.colorScheme='dark';document.documentElement.dataset.theme='dark';}}}catch(e){} })()`,
          }}
        />
        <GoogleOAuthProvider clientId={process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID ?? ""}>
          <ThemeProvider>
            <AuthProvider>
              <AudioPlayerProvider>
                {children}
                <FloatingAudioPlayer />
              </AudioPlayerProvider>
            </AuthProvider>
          </ThemeProvider>
        </GoogleOAuthProvider>
      </body>
    </html>
  );
}
