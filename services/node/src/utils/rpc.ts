import { Connection } from "@solana/web3.js";

function createConnection(network: string, api_key: string): Connection {
  if (!api_key) {
    throw new Error("RPC_API_KEY environment variable is not set");
  }

  let url_base: string;
  switch (network) {
    case "mainnet":
      url_base = "https://mainnet.helius-rpc.com/?api-key=";
      break;
    case "devnet":
      url_base = "https://devnet.helius-rpc.com/?api-key=";
      break;
    default:
      throw new Error(`Unknown network: ${network}`);
  }

  const url = url_base + api_key;
  try {
    const connection = new Connection(url, "confirmed");
    return connection;
  } catch (e: any) {
    throw new Error(`Error occurred: ${e.message}`);
  }
}

export default createConnection;
