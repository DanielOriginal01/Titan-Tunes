"use client";

import { useState } from "react";
import Button from "./Button";
import Input from "./Input";

type AuthFormProps = {
  role: "artist" | "administrateur" | "auditeur";
  onSubmit: (email: string, password: string) => void;
};

const roleLabel = {
  artist: "artist",
  administrateur: "Administrateur",
  auditeur: "Auditeur",
} as const;

export default function AuthForm({ role, onSubmit }: AuthFormProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  return (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit(email, password);
      }}
      className="space-y-6 rounded-3xl bg-white p-8 shadow-lg shadow-slate-200/40"
    >
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Connexion {roleLabel[role]}</h1>
        <p className="mt-2 text-slate-600">Entrez vos identifiants pour accéder à votre espace.</p>
      </div>
      <div className="space-y-4">
        <label className="block text-sm font-medium text-slate-700">Email</label>
        <Input value={email} onChange={(event) => setEmail(event.target.value)} type="email" required />
      </div>
      <div className="space-y-4">
        <label className="block text-sm font-medium text-slate-700">Mot de passe</label>
        <Input value={password} onChange={(event) => setPassword(event.target.value)} type="password" required />
      </div>
      <Button type="submit">Se connecter</Button>
    </form>
  );
}
