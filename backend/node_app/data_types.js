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

// Job class
class Job extends DBObject {
        /**
     * Creates a new Job instance.
     * 
     * @param {Object} options - The job options.
     * @param {string} options._id - The unique identifier for the job.
     * @param {string} options.seed_type - The type of seed used in the job.
     * @param {string} options.plate_type - The type of plate used in the job.
     * @param {number} options.target_count - The target count for the job.
     * @param {string} options.creation_date - The date the job was created (ISO string or formatted date).
     * @param {number} options.completion_count - The number of completed tasks in the job.
     * @param {string|null} options.finish_time - The finish time of the job (ISO string or `null` if not completed).
     */
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
            this.completion_count += 1;  // Fix: Should be incrementing completion_count, not target_count.
        }

        if (this.completion_count === this.target_count) {  // Use strict equality (===)
            this.finish_time = Date.now(); // Fix: Use Date.now() for a timestamp.
        }

        await this.update(); // Fix: Await the async function properly.
    }

    async finished(){
        (this.completion_count >= this.target_count )
    }

}

// PlateType class
class PlateType extends DBObject {
    constructor({ _id, g_code, Name }) {
        super({ _id });
        this.name = Name; 
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














/**
 * Class representing a Klipper Wrapper.
 * @property {number} _id - The unique identifier for this wrapper instance.
 * @property {string} ip - The printer IP address.
 * @property {WebSocket} websocket - The WebSocket connection instance.
 * @property {number} idCounter - A counter for generating unique JSON-RPC IDs.
 * @property {JSON} status - The current status (can be of any type, adjust if needed).
 * @property {Job} current_job - The current job, which is of type {@link Job} or `null` if no job is set.
 */
class KlipperWrapper {


    constructor({ ip }) {
      this._id = 12345;
      this.ip = ip
      this.websocket = null;
      this.idCounter = 1; // for generating unique JSON-RPC ids
      this.status = "INIT"
      this.current_job = null


    }
  
    /**
     * Connect to the Moonraker WebSocket server.
     */
    async connect() {
      return new Promise((resolve, reject) => {
        try {
          // The URL and path may vary based on your configuration.
          this.websocket = new WebSocket(`ws://${this.ip}/websocket`);
          
          this.websocket.onopen = () => {
            console.log("Connected to Moonraker WebSocket.");
            resolve();
          };
          
          this.websocket.onerror = (err) => {
            reject(`WebSocket error: ${err}`);
          };

          this.websocket.addEventListener("message", (event) => this.messageListener(event));
        } catch (err) {
          reject(err);
        }
      });
    }

   

    messageListener(event) {
        try {
          const data = JSON.parse(event.data);
          // Check if this message is the response for our request.+
          if (data.method != "notify_history_changed"){
            return
          }
          console.log(data)
          // Log to a file
          fs.appendFile('log.txt', JSON.stringify(data, null, 2), (err) => {
                if (err) {
                console.error('Error writing to file', err);
                } else {
                console.log('Logged to file successfully');
                }
            });
        
            const jobEntry = data.params.find(entry => entry.job);
            if (jobEntry) {
                console.log(jobEntry.job.status); // Output: "in_progress"
                this.status = jobEntry.job.status
                if (jobEntry.job.status == "completed"){

                    console.log(this.current_job)
                    this.current_job.increment()
                    this.current_job = null
                  }
            } else {
                console.log("No job found");
            }
    
          
          

    
        } catch (err) {
          // If we fail to parse the message, ignore it.
          console.error("Error parsing JSON-RPC response:", err);
        }
    }
  
    /**
     * Send a JSON-RPC request over the WebSocket.
     * @param {string} method - The API method to call.
     * @param {object} [params={}] - Parameters to send (if any).
     * @returns {Promise} - Resolves with the result from the response.
     */
    async sendRpcRequest(method, params = {}) {
      if (!this.websocket || this.websocket.readyState !== WebSocket.OPEN) {
        throw new Error("WebSocket is not open. Please call connect() first.");
      }
  
      // Create a unique id for this request.
      const requestId = this.idCounter++;
      const request = {
        jsonrpc: "2.0",
        method,
        params,
        id: requestId,
      };
      
      // Return a promise that resolves when we receive the matching response.
      return new Promise((resolve, reject) => {
        const handleMessage = (event) => {
          try {
            const data = JSON.parse(event.data);
            // Check if this message is the response for our request.
            if (data.id === requestId) {
              // Remove the event listener once we have a response.
              this.websocket.removeEventListener("message", handleMessage);
  
              if (data.error) {
                reject(data.error);
              } else {
                resolve(data.result);
              }
            }
          } catch (err) {
            // If we fail to parse the message, ignore it.
            console.error("Error parsing JSON-RPC response:", err);
          }
        };
  
        this.websocket.addEventListener("message", handleMessage);
        // Send the JSON-RPC request.
        this.websocket.send(JSON.stringify(request));
      });
    }
    
    
    
    /**
     * @param {Job} job
     */
    async start_job(job){
        console.log("start")
        if (this.current_job != null){
            throw new Error("Job already running");
        }
        this.current_job = job
        //test if job  finished
        if (await job.finished()){
            this.current_job = null
            throw new Error("Job id not found");
        }
        console.log("2")

        //check if if valid plate type 
        let type = await PlateType.getById(job.plate_type)
        if (type == null){
            this.current_job = null
            throw new Error("Job id not found");
        }
        console.log("3")

        //write gcode file 
        //fs.appendFile('/home/rpi-klipper/printer_data/gcodes/job.gcode', type.g_code, (err) => {
        fs.writeFile('./job.gcode', type.g_code, (err) => {
            if (err) {
            this.current_job = null
            console.error('Error writing to file', err);
        }});
        console.log("4")
        //start job
        const allowedStatuses = ["ready", "cancelled", "completed","INIT"];

        //ceck staus
        if (!allowedStatuses.includes( this.status)){
                throw new Error("Klipper staus not alowed: ");
            } 
        let res = await this.sendRpcRequest("printer.print.start", {filename: "job.gcode"});
       
        console.log("5")
        //check if actualy started kinda scuff but who cares 
        let trys = 10000000;
        while(true){
            if ( this.status == "in_progress"){
                    console.log("6",this.current_job)
                    return this.current_job
            }  
            trys -= 1
            if (trys <0 ){
                console.log("6")
                this.current_job = null
                throw new Error("nevver recived in_progress staus from clipper " );
            }
        }
    }
    /**
     * Disconnect from the WebSocket.
     */
    disconnect() {
      if (this.websocket) {
        this.websocket.close();// cp 
        console.log("Disconnected from Moonraker WebSocket.");
      }
    }
}
module.exports = { Job, PlateType ,KlipperWrapper};


// // Usage example:
// (async () => {
//     const klipper = new KlipperWrapper({
//       g_code: "test.gcode", // or the full path/filename as required by your Moonraker instance
//       ip: "192.168.2.22",
//     });
//     await klipper.connect()
//     let res = await klipper.sendRpcRequest("printer.print.start", {filename: "test.gcode"})
   
//     console.log(res)
//     // Continue with other non-blocking operations here.
//   })();