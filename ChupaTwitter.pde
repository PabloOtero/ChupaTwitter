import java.util.*;
import java.text.*;
import java.util.List;
import java.util.Date;
import java.io.BufferedWriter;
import java.io.FileWriter;

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.internal.util.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

PrintWriter BufferedWriter;

ArrayList<String> words = new ArrayList(); //Build an ArrayList to hold all of the words that we get from the imported tweets

double lat;
double lon;
double res;
String resUnit;

long lasttweet;

String outfilename; 
String outfilename_geo;

int savedTime;

Query query;

void setup() {
  //Set the size of the stage, and the background to black.
  //size(1300,800);
  //background(0);
  //smooth();

  //Credentials (write in XXX your own credential from Twitter)
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("XXX");              
  cb.setOAuthConsumerSecret("XXX");                              
  cb.setOAuthAccessToken("XXX");                   
  cb.setOAuthAccessTokenSecret("XXX");


  //Make the twitter object and prepare the query
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();

 //int count=0;
 for (int count = 0; count < 7; count++) {

    if (count == 0) {
      query = new Query("(sea temperature) OR (ocean temperature) OR (marine temperature) OR (temperatura mar -plata) OR (temperatura oceano)");
      outfilename = "Twitter_Temperature.txt";
      outfilename_geo = "Twitter_Temperature_geo.txt";
      println("Dentro");
    } 
    else if (count == 1) {
      query = new Query("(sea currents) OR (ocean currents) OR (marine currents) OR (corrientes mar) OR (corrientes oceano) OR (corrientes marinas)");
      outfilename = "Twitter_Currents.txt";
      outfilename_geo = "Twitter_Currents_geo.txt";
    } 
    else if (count == 2) {   
      query = new Query("(sea salinity) OR (ocean salinity) OR (marine salinity) OR (salinidad mar) OR (salinidad oceano)");
      outfilename = "Twitter_Salinity.txt";
      outfilename_geo = "Twitter_Salinity_geo.txt";
    } 
    else if (count == 3) {
      query = new Query("(algal bloom) OR (bloom algas)");
      outfilename = "Twitter_AlgalBloom.txt";
      outfilename_geo = "Twitter_AlgalBloom_geo.txt";
    } 
    else if (count == 4) {
      query = new Query("(sea ice -cream -walrus) OR (hielo marino) OR (hielo mar)");
      outfilename = "Twitter_Ice.txt";
      outfilename_geo = "Twitter_Ice_geo.txt";
    } 
    else if (count == 5) { 
      query = new Query("(height wave -suzanna -CariCOOS -prichnichikova -NewhavenTownWx -tsunami -CCWM-b-46026) OR (period wave -suzanna -CariCOOS -prichnichikova -NewhavenTownWx -tsunami -CCWM-b-46026) OR (peak wave -suzanna -CariCOOS -prichnichikova -NewhavenTownWx -tsunami -CCWM-b-46026)");
      outfilename = "Twitter_Waves.txt";
      outfilename_geo = "Twitter_Waves_geo.txt";
    } 
    else if (count == 6) { 
      query = new Query("(sea tide) OR (ocean tide) OR (mar marea) OR (oceano marea)");
      outfilename = "Twitter_Tides.txt";
      outfilename_geo = "Twitter_Tides_geo.txt";
    } 
    
    query.setSince("2013-11-25");
    query.setUntil("2013-12-02");
    query.setCount(100);   

    int contador=0;

    //Try making the query request.
    try {

      QueryResult result = twitter.search(query);

      while (query!=null) { 

        List<Status> tweets = (ArrayList) result.getTweets();
        println(tweets.size());

        for (int i = 0; i < tweets.size(); i++) {
          Status t=(Status) tweets.get(i);
          User u=(User) t.getUser();
          String user=u.getName();
          String msg = t.getText();
          Date date = t.getCreatedAt();

          /*
                 //Break the tweet into words (used later in the drawing section)
           String[] input = msg.split(" ");
           for (int j = 0;  j < input.length; j++) {
           //Put each word into the words ArrayList
           words.add(input[j]);
           }
           */

          // Splitting the date in day-month-hour-min-sec
          DateFormat format = new SimpleDateFormat("dd/MM/yyyy"); 
          DateFormat ObjYear = new SimpleDateFormat("yyyy");
          String MyYear = ObjYear.format(date);         
          DateFormat ObjMonth = new SimpleDateFormat("MM");
          String MyMonth = ObjMonth.format(date);
          DateFormat ObjDay = new SimpleDateFormat("dd");
          String MyDay = ObjDay.format(date);
          DateFormat ObjHour = new SimpleDateFormat("kk");
          String MyHour = ObjHour.format(date);
          DateFormat ObjMin = new SimpleDateFormat("mm");
          String MyMin = ObjMin.format(date);
          DateFormat ObjSec = new SimpleDateFormat("ss");
          String MySec = ObjSec.format(date);


          appendTextToFile(outfilename, MyDay + "/" + MyMonth + "/" + MyYear + " " + MyHour + ":" + MyMin + ":" + MySec + ", " + user + ", {" + msg + "}" );
          contador = contador +1;

          if (t.getGeoLocation()!= null) {               
            GeoLocation loc=t.getGeoLocation();
            lon = loc.getLongitude();
            lat = loc.getLatitude();        
            String MyLon = Double.toString(loc.getLongitude());
            String MyLat = Double.toString(loc.getLatitude());

            println(lon + " " + lat + " Tweet by " + user + " at " + date + msg);

            appendTextToFile(outfilename_geo, MyLon + ", " + MyLat + ", " + MyDay + "/" + MyMonth + "/" + MyYear + " " + MyHour + ":" + MyMin + ":" + MySec + ", " + user + ", {" + msg + "}" );
          }
        }


        query=result.nextQuery();

        lasttweet = result.getMaxId();
        //query.getSinceId(lasttweet);

        if (query!=null) {
          result=twitter.search(query);
          lasttweet = result.getMaxId();
        }
      }
    }
    catch (TwitterException te) {
      println("Couldn't connect: " + te);
    }

    println("Total tweets: " + contador);
    println("Last tweet: " + lasttweet);

    savedTime = millis();
    boolean doonce = true;
    while ( (millis() - savedTime) < 30000) {
      if (doonce) { 
       println( " Waiting " );
       doonce = false;
      } 
    }
  }
}


/**
 * Appends text to the end of a text file located in the data directory, 
 * creates the file if it does not exist.
 * Can be used for big files with lots of rows, 
 * existing lines will not be rewritten
 */
void appendTextToFile(String filename, String text) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
} 


