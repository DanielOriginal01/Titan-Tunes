export type User = {
  id: string;
  name: string;
  email: string;
  role: "artist" | "admin";
};

export type Artist = User & {
  tracks: Track[];
  followers: number;
};

export type Track = {
  id: string;
  title: string;
  plays: number;
  earnings: number;
};

export type Payout = {
  id: string;
  amount: number;
  status: "pending" | "paid" | "failed";
  method: "MobileMoney" | "Bank";
};

export type Royalty = {
  id: string;
  period: string;
  amount: number;
  status: "due" | "paid";
};
