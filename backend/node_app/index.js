// Import required modules
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const { Job, PlateType,KlipperWrapper } = require('./data_types');
const morgan = require('morgan');

// MongoDB connection URL and database/collection names
const MONGO_URL = 'mongodb://root:password123@192.168.2.24:27017';
const DB_NAME = 'jobdata';
const COLLECTION_JOBS = 'jobs';
const COLLECTION_PLATE_TYPE = 'PLATE_TYPES';

// Initialize Express
const app = express();
const port = 3000;

// Middleware to parse JSON request bodies
app.use(express.json());
app.use(morgan('dev')); 


//initialize Klipper

const klipper = new KlipperWrapper({ip: "192.168.2.24"})

// Connect to MongoDB
const client = new MongoClient(MONGO_URL);
(async () => {
    try{
        await klipper.connect()
    } catch (err) {
        console.error('Failed to connect to Klipper:', err);
        process.exit(1);
    }
    try {
        await client.connect();
        console.log('Connected to MongoDB');
        const db = client.db(DB_NAME);
        Job.dbCollection = db.collection(COLLECTION_JOBS);
        PlateType.dbCollection = db.collection(COLLECTION_PLATE_TYPE);
        
        
        // ------------------------------------------------ Jobs ------------------------------------------
        app.get('/jobs', async (req, res) => {
            try {
                const jobs = await Job.getAll();
                res.status(200).json(jobs);
            } catch (err) {
                res.status(500).json({ message: 'Error fetching jobs' });
            }
        });

        app.get('/jobs/:id', async (req, res) => {
            try {
                const job = await Job.getById(req.params.id);
                if (!job) return res.status(404).json({ message: 'Job not found' });
                res.status(200).json(job);
            } catch (err) {
                res.status(500).json({ message: 'Error fetching job' });
            }
        });

        app.post('/jobs', async (req, res) => {
            try {
                const job = await Job.create(req.body);
                res.status(201).json(job);
            } catch (err) {
                res.status(500).json({ message: err.message });
            }
        });

        app.put('/jobs/:id', async (req, res) => {
            try {
                const job = await Job.getById(req.params.id);
                if (!job) return res.status(404).json({ message: 'Job not found' });
                Object.assign(job, req.body);
                await job.update();
                res.status(200).json(job);
            } catch (err) {
                res.status(400).json({ message: err.message });
            }
        });

        app.delete('/jobs/:id', async (req, res) => {
            try {
                const job = await Job.getById(req.params.id);
                if (!job) return res.status(404).json({ message: 'Job not found' });
                await job.delete();
                res.status(200).json({ message: 'Job deleted' });
            } catch (err) {
                res.status(500).json({ message: 'Error deleting job' });
            }
        });


        app.post('/run/:id', async (req, res) => {
            try {
               const job = await Job.getById(req.params.id);
               if (!job) return res.status(404).json({ message: 'Job not found' });
               let ret_job = await klipper.start_job(job)
               res.status(200).json(ret_job);
            } 
            catch (err) {
                res.status(500).json({ message: err.message });
            }
        });



        
        
        
        
        
        
        //--------------------------------- PLATES -------------------------------------------

        app.get('/plates', async (req, res) => {
            try {
                const jobs = await PlateType.getAll();
                res.status(200).json(jobs);
            } catch (err) {
                res.status(500).json({ message: 'Error fetching jobs' });
            }
        });

        app.get('/plates/:id', async (req, res) => {
            try {
                const job = await PlateType.getById(req.params.id);
                if (!job) return res.status(404).json({ message: 'plates not found' });
                res.status(200).json(job);
            } catch (err) {
                res.status(500).json({ message: 'Error fetching job' });
            }
        });

        app.post('/plates', async (req, res) => {
            try {
                const job = await PlateType.create(req.body);
                res.status(201).json(job);
            } catch (err) {
                res.status(500).json({ message: err.message });
            }
        });

        app.put('/plates/:id', async (req, res) => {
            try {
                const job = await PlateType.getById(req.params.id);
                if (!job) return res.status(404).json({ message: 'plates not found' });
                Object.assign(job, req.body);
                await job.update();
                res.status(200).json(job);
            } catch (err) {
                res.status(400).json({ message: err.message });
            }
        });

        app.delete('/plates/:id', async (req, res) => {
            try {
                const job = await PlateType.getById(req.params.id);
                if (!job) return res.status(404).json({ message: 'plates not found' });
                await job.delete();
                res.status(200).json({ message: 'Job deleted' });
            } catch (err) {
                res.status(500).json({ message: 'Error deleting job' });
            }
        });








        // Start the Express server
        app.listen(port, () => {
            console.log(`Server is running on http://localhost:${port}`);
        });
    } catch (err) {
        console.error('Failed to connect to MongoDB:', err);
        process.exit(1);
    }
})();

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('Closing MongoDB connection');
    await client.close();
    process.exit(0);
});
