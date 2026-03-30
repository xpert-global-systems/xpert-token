export default function handler(req, res) {
  const { address } = req.query;

  const metadata = {
    name: "Your Meme Token",
    symbol: "MEME",
    description: "A meme token launched using the Base Token Launch Kit.",
    chain: "base",
    address,
    website: "https://yourbrand.xyz",
    twitter: "https://twitter.com/yourbrand",
  };

  res.status(200).json(metadata);
}
