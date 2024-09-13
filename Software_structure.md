Software overview (This file tracks desinge dessisions, we had, like which part of the software does what)

# Backend
  - Probaply is going to be a MongoDB database
  - Is used to to store mashine jobs and teached plates
  - Ther is going to be no users, as there is only one mashine in existens as of writing this application

# Frontend
## Pages:
### Jobs:
This page is used to configure a job e.g. select the breed that is going to be seeded. And what type of needles and plates are in use. Time should be recorded by the Mashine / Frontend in the backround.<br>
There is also going to be the ability to look at jobs in the past (the ones that are stored in the DB) but the user can not edit them.
### Mashine contorl:
This page is going to be used to control the mashien in X, Y, Z and pump on or of. It is also going to be used to record new plates and save them to the DB
### Mainpage:
This page is going to be used to start stop and pause a current job (needs to work together with the Jobs page, need further discussion or if it is better to merge the main and job page)

# APIs:
There is going to be the moonraker api for the frontend to contorl the mashine e.g. send it movement commands for the backend we need to desige our own api. 
