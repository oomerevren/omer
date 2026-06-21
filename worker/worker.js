const { Worker } = require('bullmq');
const Redis = require('ioredis');
require('dotenv').config();

const connection = new Redis({
  host: process.env.REDIS_HOST || 'redis',
  port: 6379,
  password: process.env.REDIS_PASSWORD,
  maxRetriesPerRequest: null,
});

const queues = ['news_ingest', 'content_generation', 'fact_check', 'social_publish'];

queues.forEach(queueName => {
  const worker = new Worker(queueName, async job => {
    console.log(`[Worker] Processing job ${job.id} from queue ${queueName}`);
    // İş mantığı burada n8n webhook'unu tetikleyebilir veya doğrudan DB'ye yazabilir.
    return { success: true };
  }, { connection });

  worker.on('completed', job => {
    console.log(`[Worker] Job ${job.id} from ${queueName} completed.`);
  });

  worker.on('failed', (job, err) => {
    console.error(`[Worker] Job ${job.id} from ${queueName} failed: ${err.message}`);
  });
});

console.log('🚀 BullMQ Workers are running...');
