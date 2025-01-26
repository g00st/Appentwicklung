// Import required modules
const express = require('express');
const { MongoClient } = require('mongodb');

// MongoDB connection URL and database/collection names
const mongoUrl = 'mongodb://root:password123@localhost:27017'; // Change to your MongoDB connection string if needed
const dbName = 'jobdata';
const collectionName = 'jobs';

// Initialize Express
const app = express();
const port = 3000;

// Middleware to parse JSON request bodies
app.use(express.json());

// Connect to MongoDB
const client = new MongoClient(mongoUrl);
(async () => {
    try {
        await client.connect();
        console.log('Connected to MongoDB');
        const db = client.db(dbName);
        const collection = db.collection(collectionName);

        // Route to store JSON data
        app.post('/store', async (req, res) => {
            try {
                const jsonData = req.body;
                const result = await collection.insertOne(jsonData);
                res.status(201).send({ message: 'Data stored successfully', id: result});
            } catch (err) {
                console.error('Error storing data:', err);
                res.status(500).send({ message: 'Failed to store data' });
            }
        });

        // Route to load all JSON data
        app.get('/load', async (req, res) => {
            try {
                const data = await collection.find({}).toArray();
                res.status(200).send(data);
            } catch (err) {
                console.error('Error loading data:', err);
                res.status(500).send({ message: 'Failed to load data' });
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

