import express from 'express';
import { 
  LoginUser, 
  RegisterUser,  
  UpdateAB,
  userProfile,
  getAB
} from '../controllers/userController.js';
import authMiddleware from '../middleware/authMiddleware.js';

const userRouter = express.Router();

userRouter.post('/register', RegisterUser);
userRouter.post('/login', LoginUser);
userRouter.get('/profile',authMiddleware, userProfile)
userRouter.put('/update-ab', authMiddleware, UpdateAB);
userRouter.get('/ab', authMiddleware, getAB);

export default userRouter;