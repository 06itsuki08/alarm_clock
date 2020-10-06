class Alarm{
 int id;
 DateTime time;
 String description;
 String soundPath;
 List<int> repeat;
 bool vibration;

 Alarm(
   this.time,
   this.description,
   this.soundPath,
   this.repeat,
   this.vibration
 );

 setAlarm(DateTime time,String description,String soundPath,List<int> repeat,bool vibration){
   new Alarm(
     time,
     description,
     soundPath,
     repeat,
     vibration
   );
 }

 }