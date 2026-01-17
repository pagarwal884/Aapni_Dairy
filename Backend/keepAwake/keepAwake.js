import cron from "node-cron";
import axios from "axios";

const BACKEND_URL = process.env.BACKEND_URL; // your render URL

if (BACKEND_URL) {
  cron.schedule("*/5 * * * *", async () => {
    try {
      await axios.get(`${BACKEND_URL}/health`);
      console.log("🔁 Keep-alive ping sent");
    } catch (err) {
      console.error("❌ Keep-alive failed:", err.message);
    }
  });
}
