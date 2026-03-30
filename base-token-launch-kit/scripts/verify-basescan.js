const { run } = require("hardhat");

async function main() {
  const contractAddress = process.env.CONTRACT_ADDRESS;
  const name = process.env.TOKEN_NAME;
  const symbol = process.env.TOKEN_SYMBOL;
  const supply = process.env.TOKEN_SUPPLY;

  if (!contractAddress) {
    throw new Error("CONTRACT_ADDRESS not set");
  }

  await run("verify:verify", {
    address: contractAddress,
    constructorArguments: [name, symbol, supply],
  });

  console.log("Verified on BaseScan:", contractAddress);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
