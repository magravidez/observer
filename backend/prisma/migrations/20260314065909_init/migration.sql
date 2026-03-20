-- CreateTable
CREATE TABLE "observer" (
    "id" SERIAL NOT NULL,
    "temperature" DOUBLE PRECISION NOT NULL,
    "humidity" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "observer_pkey" PRIMARY KEY ("id")
);
