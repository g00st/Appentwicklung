# Seeding robot controll App
This repository contains the controll app fo the seeding robot written in Flutter and the management backend written in node.js and database.

## Repository
### Sturcture
The front and backend are in two unrelated branches meaning<br>
`frontend` branch only contains the App written in Flutter<br>
`backend` branch only contains the node.js backend and the needed database

### Instalation
#### Frontend:
```bash
git clone -b frontend https://github.com/g00st/Appentwicklung.git
```
`ToDo:` add instructions on how to setup the Flutter app

#### Backend:
```bash
git clone -b backend https://github.com/g00st/Appentwicklung.git
```
`ToDo:` add instructions on how to setup the Node.js backend with DB



## Jobs
  - Jobs will be saved in a database.
  - Jobs should include: start time, end time, total time, time actually used for seeding, and time spent replacing a full plate.
  - Jobs will be immutable from the frontend (once saved, they can only be viewed).
  - Plate configurations are saved as GCODE.

## Machine Control
  - Home the machine.
  - Control movement in X, Y, Z axes and toggle the vacuum pump on and off.
  - Enable/disable motors.

## Architecture
![alt text](/images/Architecture.svg)

## App Flow
![alt text](/images/App_Flow.svg)

## Current roboter state
(homing and movemend works via app)
![alt text](/images/work_in_progress.jpg)

