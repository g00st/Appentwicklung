# Appentwicklung

## Saehrobotter:
  - Frontend contorl Robot via. Moonraker API. x y z control.
  - Maby Camera, for remote contorl.(If there is time left, and we still have motivation)
  - Teach new Plates, and save them to own database.
  - Save current job state to DB

## Jobs
  - Jobs are going to be saved as JSON and are going to be send betwen the frontend and backend.
  - Jobs should include Start time, End time, full time, time actually used for seeding, time spend replacing full plate.
  - Jobs are going to be immutabel from the frontend (After they are saved, they can only be viewed).

## Plates
  - Decide on how plates are saved plain GCODE or JSON
  - How much configuration is made available for the user e.g. can the operator decide the seed storage location or not. Can he decide the travel hight of the needle. Or can the user onyl record the drop of possition.

## Mashin control
  - Movement contorl in X, Y, Z and turn the Vacuum pump on and off.
