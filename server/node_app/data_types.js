const { ObjectId } = require('mongodb');
const WebSocket = require('ws');
const fs = require('fs');
const { time } = require('console');

class DBObject {
    static dbCollection;
    
    constructor({_id}) {
        this._id = _id;
    }

    static async getById(id) {

        const data = await this.dbCollection.findOne({ _id:  new ObjectId(id) });
        return data ? new this(data) : null;
    }

    static async getAll() {
        const data = await this.dbCollection.find({}).toArray();
        return data.map(item => new this(item));
    }

    static async create(json) {
        const validation = this.validate(json);
        if (!validation.valid) throw new Error(validation.message);

        const result = await this.dbCollection.insertOne(json);
        return new this({ ...json, _id: result.insertedId });
    }

    async update() {
        const validation = this.constructor.validate(this);
        if (!validation.valid) throw new Error(validation.message);
        await this.constructor.dbCollection.updateOne(
            { _id: new ObjectId(this._id) },
            { $set: this }
        );
    }

    async delete() {
        await this.constructor.dbCollection.deleteOne({ _id: new ObjectId(this._id) });
    }
}

class Job extends DBObject {
    constructor({ _id, seed_type, plate_type, target_count, creation_date, completion_count, finish_time }) {
        super({ _id });
        this.seed_type = seed_type;
        this.plate_type = plate_type;
        this.target_count = target_count;
        this.creation_date = creation_date;
        this.completion_count = completion_count;
        this.finish_time = finish_time;
    }

    static validate(job) {
        const requiredFields = ['seed_type', 'plate_type', 'target_count', 'creation_date', 'completion_count', 'finish_time'];
        for (const field of requiredFields) {
            if (!(field in job)) {
                console.error(`Missing field: ${field}` )
                return { valid: false, message: `Missing field: ${field}` };
            }
        }
        return { valid: true };
    }

    async increment() {
        if (this.completion_count < this.target_count) {
            this.completion_count += 1;  
        }

        if (this.completion_count === this.target_count) {  
            this.finish_time = Date.now(); 
        }

        await this.update(); 
    }

    async finished(){
        return (this.completion_count >= this.target_count )
    }

}

class PlateType extends DBObject {
    constructor({ _id, g_code, name }) {
        super({ _id });
        this.name = name; 
        this.g_code = g_code;
    }
    static validate(plateType) {
        const requiredFields = ['name', 'g_code'];
        for (const field of requiredFields) {
            if (!(field in plateType)) {
                console.error(`Missing field: ${field}` )
                return { valid: false, message: `Missing field: ${field}` };
            }
        }
        return { valid: true };
    }
}

module.exports = { Job, PlateType};


