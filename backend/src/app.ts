import express from "express";
import cors from "cors";

import { database } from "./config/db";

import userRouter from "./routes/user.route";
import appointmentRouter from "./routes/appointment.route";

const port = process.env.PORT || 3000;

database();
const app = express();

app.use(express.json());
app.use(cors())

app.use("/accounts", userRouter);
app.use("/appointments", appointmentRouter);

app.listen(port, () => {
    console.log(`Server is running`);
});
