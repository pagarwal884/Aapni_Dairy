import cors from 'cors';
import 'dotenv/config';
import express from 'express';
import connectDB from './config/mongoDB.js';
import userRouter from './routes/userRoutes.js';
import customerRouter from './routes/customerRoutes.js';
import entryRoute from './routes/entryRouting.js';
const app = express();
const port = process.env.PORT || 5000;

// middleware
app.use(express.json());   
app.use(cors());

// Connect Database
connectDB();

// API Endpoints
app.use('/api/user', userRouter)
app.use('/api/customer',customerRouter)
app.use('/api/entry', entryRoute)
app.get('/', (req, res) => {
  res.send("API Working");
});


app.listen(port, '0.0.0.0', () => {
  console.log("Server started at: " + port);
});
