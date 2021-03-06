/*
 * Finger detection class.
 * (c) Antonio Molinaro 2011 
 * http://code.google.com/p/blobscanner/.
 */

class FingerDetector {
  BoundingBox bBox;
  public PVector hand, wrist, a, b,c,d, pinky,thumb, prevThumb, prevPinky; 
  public PVector[] prevFingers;
  public PVector foreFinger, midFinger, ringFinger, pinkyFinger;
  
  float w, h, handLength;
  PImage out;
  
  FingerDetector(PImage _out, PVector _hand, PVector _wrist){
    out=_out;
    w=out.width;
    h=out.height;
    
    hand=_hand;
    wrist=_wrist;
    
    if( hand!=null && wrist !=null){
      //Extend palm up by 1/4 of the dist from wrist to palm
      //(Brings it right up to the knuckle level, instead of the plam)
      PVector handVec = PVector.sub(hand, wrist);
      handVec.mult(1.0/4.0);
      hand.add(handVec);
      
      removePalm();
    }
  }
  
  FingerDetector(PImage _out, PVector _hand, PVector _wrist, PVector _prevThumb, PVector _prevPinky, PVector[] _prevFingers){
    this(_out,_hand,_wrist);
    
    prevThumb =_prevThumb;
    prevPinky=_prevPinky;
    prevFingers=_prevFingers;
  }
  
  
  //Returns true if possible Thumb is not too close to hand, 
  //false otherwise
  boolean inThumbRange(PVector possibleThumb){
    if(hand!=null && possibleThumb!=null && wrist!=null){
      PVector wristToThumb = PVector.sub(possibleThumb, wrist);
      PVector handToThumb = PVector.sub(possibleThumb, hand);
      
      if(handToThumb.mag()>handLength/4 && handToThumb.mag()<handLength*1.5){
        if(wristToThumb.mag()>handLength/4 && wristToThumb.mag()<handLength*1.5){
          return true;
        }
      }
    }
    
    
    return false;
  }
  
  void removePalm(){
    PVector handPar = PVector.sub(hand, wrist);
    handPar.normalize();
    
    PVector wristPerp = new PVector();
    PVector wristPerp4 = new PVector();
    
    float perpX = handPar.x;
    float perpY = handPar.y;
    
    wristPerp.x = -1*perpY;
    wristPerp.y = perpX;
    
    wristPerp4.x= perpY;
    wristPerp4.y=-1*perpX;
    
    //Checks that they aren't of length 0
    //TRYING: REMOVING THIS
    //if(wristPerp.mag()>0){
      //Vector One of the bounding box
      wristPerp = wristExtensions(wristPerp);
      //Vector Four of the bounding box
      wristPerp4 = wristExtensions(wristPerp4);
     
      PVector hand2 = new PVector();
      hand2.x=wristPerp.x;
      hand2.y=wristPerp.y;
      
      hand2.sub(wrist);
      hand2.add(hand);
      
      PVector hand3 = new PVector();
      hand3.x=wristPerp4.x;
      hand3.y=wristPerp4.y;
      
      hand3.sub(wrist);
      hand3.add(hand);
      
      PVector handLength = PVector.sub(hand,wrist);
      handLength.mult(-1);
      handLength.add(wrist);
      
      wristPerp.sub(wrist);
      wristPerp4.sub(wrist);
      
      //Put on bit behind the wrist
      wristPerp.add(handLength);
      wristPerp4.add(handLength);
      
      a=wristPerp;
      b=hand2;
      c =wristPerp4;
      d=hand3;
      
      
      bBox = new BoundingBox(wristPerp, hand2, hand3, wristPerp4);
      if(wristPerp.x>0 || wristPerp.y>0 || wristPerp.x<w || wristPerp.y<h){
        blackenPalm();
      } 
      
    //}  
  }
  
  //Presupposes non-null thumb
  boolean openHand(){
   
    PVector thumbLength = PVector.sub(thumb, wrist);
    
    if(thumbLength.mag()<handLength){
      return false;
    }
    else{
      return true;
    }
  }
  
  PVector getPinky(){
    return pinky;
  }
  
  PVector thumbDetection(){
    PVector thumb1 = null;
    PVector thumb2 = null;
    
    float length1 = 0.0f; 
    float length2= 0.0f;

    
    if(a!=null && b!=null && c!=null && d!=null){
     // println("To");
      if(a.x>0 && b.x>0 && a.y>0 && b.x>0){
      //  println("Figure");
        thumb1 = thumbPotentials(a,b);
        if(thumb1!=null){
          length1 = thumb1.z;
          thumb1.z=0.0f;
        }
        
      }
      if(c.x>0 && d.x>0 && c.y>0 && d.y>0){
        //println("This");
        thumb2 = thumbPotentials(c,d);
        if(thumb2!=null){
          length2 = thumb2.z;
          thumb2.z = 0.0f;
        }
      }
    }
    
    if(thumb1!=null && thumb2!=null){
      if(inThumbRange(thumb1) && inThumbRange(thumb2)){
        if(length1>length2){
          thumb=thumb1;
          pinky=thumb2;
          return thumb1;
        }
        else{
          pinky=thumb1;
          thumb=thumb2;
          return thumb2;
        }
      }
      else if(inThumbRange(thumb1)){
        thumb=thumb1;
        return thumb1;
      }
      else if(inThumbRange(thumb2)){
        thumb=thumb2;
        return thumb2;
      }
    }
    else if(thumb1!=null){
      if(inThumbRange(thumb1)){
        return thumb1;
      }
    }
    else if(thumb2!=null){
      if(inThumbRange(thumb2)){
        return thumb2;
      }
    }
    
    if(prevThumb!=null){
      PVector thumb3 =closestWhiteTo(prevThumb);
      if(thumb3!=null){
        return thumb3;
      }
    }
    
    
    
    /**
    if(thumb1!=null && thumb2!=null){
      
      if(length1>handLength/5 && length1<handLength && length2>handLength/5 && length2<handLength){
        if(length1>length2){
          pinky=thumb2;
          thumb = thumb1;
          return thumb1;
        }
        else{
          pinky = thumb1;
          thumb = thumb2;
          return thumb2;
        }
      }
      else if(length1>handLength/5 && length1<handLength){
        thumb = thumb1;
        return thumb1;
      }
      else if(length2>handLength/5 && length2<handLength){
        thumb = thumb2;
        return thumb2;
      }
    }
    else if(thumb1!=null && thumb2==null){
      if(length1>handLength/5 && length1<handLength){
        thumb = thumb1;
        return thumb1;
      }
    }
    else if(thumb2!=null && thumb1==null){
      if(length2>handLength/5 && length2<handLength){
        //println("Possibility 6");
        thumb = thumb2;
        return thumb2;
      }
    }
    
    if(prevThumb!=null){
      thumb =closestWhiteTo(prevThumb);
     
      //if(prevPinky!=null){
      //  pinky = closestWhiteTo(prevPinky);
      //}
      if(thumb!=null){
        //GETTING RID OF THIS TO SEE HOW LONG THE MAX leftThumbNullCounter SHOULD BE
        //println("It was the prev Thumb check! Thumb was: "+thumb);
      }
      
      return thumb;
    }
    */
    return null;
  }
  
  /**
  * Finds closest white pixel to previous, within a measure
  *
  */
 public PVector closestWhiteTo(PVector prev){
      //TESTING: 20 again, since I'm working on projective space with the thumb
      int maxDist = 20;
      int index = (int)(prev.x+prev.y*w);
      if(index>0 && index<out.pixels.length){
        if(brightness(out.pixels[index])==255){
          return prev;
        }
      }
      
      for(int x=(-1*maxDist+(int)prev.x); x<=(maxDist+(int)prev.x); x++){
        for(int y=(-1*maxDist+(int)prev.y); y<=(maxDist+(int)prev.y); y++){
          index= (int)(x+y*w);
          
          if(index>0 && index<out.pixels.length){
            //print("This is gonna suck, brightness: "+brightness(out.pixels[index]));
            if(brightness(out.pixels[index])==255){
              return new PVector(x,y);
            }
          }
        }
      }
      
      return null;
  }
  
  //Startpos will be the one closest to the wrist, endPos closest to the hand
  PVector thumbPotentials(PVector startPos, PVector endPos){
    
    boolean onlyOne = false;
    boolean hitWhite = false;
    
    PVector startIncrement = PVector.sub(startPos, wrist);
    PVector endIncrement = PVector.sub(endPos, hand);
    
    PVector difference = PVector.sub(endPos, startPos);
    float handLength = difference.mag();
    
    this.handLength = handLength;
    
    PVector distToHand = new PVector(endIncrement.x, endIncrement.y);
    
    startIncrement.normalize();
    endIncrement.normalize();
    
    PVector thumbPos = null;
    
    float distExtended = 0.0f;
    
    //Has the max search value as handLength*2, which strikes me as far too much
    //TRYING: just handLength, I think I replaced that for a reason though, not sure
    while(!onlyOne && distToHand.mag() <(handLength*1.5)){
      
      startPos.add(startIncrement);
      endPos.add(endIncrement);
      distExtended++;
      
      distToHand = PVector.sub(endPos, hand);
      
      PVector diff = PVector.sub(endPos,startPos);
      float distance = diff.mag();
      diff.normalize();
      PVector movePnt = new PVector(startPos.x,startPos.y);
      
      int whiteCnt = 0;
      float savedX = 0.0f;
      float savedY = 0.0f;
      
      while(PVector.sub(movePnt, startPos).mag() <distance){
        
        movePnt.add(diff);
        
        int index = (int)movePnt.x+(int)movePnt.y*(int)w;
        if(index>=0 &&out.pixels.length>index){
          if(brightness(out.pixels[index])==255 && red(out.pixels[index])==255){
            whiteCnt++;
            //TRYING TO DO THIS
            //if(thumbChecker(new PVector(movePnt.x,movePnt.y))){
              savedX = movePnt.x;
              savedY = movePnt.y;
            //}
          }
        }
      }
      if(whiteCnt>0){
        //If you haven't hit white yet
        if(!hitWhite){
          hitWhite=true;
        }
        //If you have hit white already, and there's only one you have a thumb
        else{
          if(whiteCnt==1){
            onlyOne=true;
            thumbPos = new PVector(savedX, savedY, distExtended);
          }
        }
      }
    }
    
    
   return thumbPos;
  }
  
  PImage getImage(){
    return out;
  }
  
  PVector wristExtensions(PVector wristVec){
   
    PVector orig = new PVector();
    orig.x=wristVec.x;
    orig.y=wristVec.y;
    
    wristVec.add(wrist);
    
    boolean onWrist = true;
    while(onWrist){
      wristVec.add(orig);
      
     int index = (int)wristVec.x+(int)wristVec.y*(int)w;
      if(index>0 && index< out.pixels.length){
        if(brightness(out.pixels[index])==0){
          onWrist=false;
        }
        
      }
      else{
        onWrist=false;
      }
    }
    
    return wristVec;
  }
  
  
  //Just code here in case I decide I need it for later
  //Prolly actually use thumb and handPos (for middle). With those you 
  //could determine what each one is. 
  //For now, just uses thumb
  void assignFingers(){
    PVector[] fingers = pickOutFingers();
    int fingerCnt = 0;
    for(PVector finger: fingers){
      if(finger!=null){
        fingerCnt++;
        
      }
    }
    
    if(fingerCnt==4 && thumb!=null){
      //We already know they're all nonNull
      int placedCnt = 0;
      while(placedCnt<4){
        float distance =1000.0f;
        PVector minimum=null;
        for(PVector finger: fingers){
          if(finger!=null){
            PVector fingDiff = PVector.sub(finger, thumb);
            if(fingDiff.mag()<distance){
              minimum=fingDiff;
              distance=fingDiff.mag();
            }
            
        
          }
        }
        
        if(minimum!=null){
          if(placedCnt==0){
            foreFinger=minimum;
          }
          else if(placedCnt==1){
            midFinger=minimum;
           
          }
          else if(placedCnt==2){
           ringFinger=minimum; 
          }
          else if(placedCnt==3){
            pinkyFinger=minimum;
          }
          placedCnt++;
        }
        else{
          //You didn't have a minimum this time, go ahead and finish.
          placedCnt=5;
        }
        
      }
    }
  }
  
  PVector[] pickOutFingers(){
    //b and d are closest to the hand
   
    PVector[] fingers = new PVector[4];
    int pointer = 0; 
    
    if(b==null || d==null){
      return fingers;
    }
    
    PVector startPos = PVector.sub(b,hand);
    PVector endPos = PVector.sub(d,hand);
     
    //Make it wider
    startPos.mult(2);
    endPos.mult(2);
    
    startPos.add(hand);
    endPos.add(hand);
    PVector increment = PVector.sub(hand,wrist);
    increment.normalize();
    
    float difference = 0.0f;
    
    float savedX=0.0f;
    float savedY=0.0f;
    while(difference<handLength*2 && pointer<fingers.length){
      startPos.add(increment);
      endPos.add(increment);
      difference++;
      
      PVector movePnt = new PVector(startPos.x,startPos.y);
      
      PVector diff = PVector.sub(endPos, startPos);
      float distance = diff.mag();
      diff.normalize();
      
      boolean white=false;
      boolean black=false;
      int whiteCnt = 0;
      
      while(PVector.sub(movePnt, startPos).mag()<distance && pointer<fingers.length){
        movePnt.add(diff);
        
        
        int index = (int)movePnt.x+(int)movePnt.y*(int)w;
        if(index>=0 &&out.pixels.length>index){
          if(brightness(out.pixels[index])==255 && red(out.pixels[index])==255){
            
            //If previously black
            if(black){
              black = false;
            }
            //If previously white
            if(white){
              whiteCnt++;
              savedX = movePnt.x;
              savedY = movePnt.y;
            }            
            white=true;
          }
          else if(brightness(out.pixels[index])==0){
            
            //If previously white
            if(white){
              //If white count is less than 3, you found a finger!
              if(whiteCnt<3 && whiteCnt>0){
                //If not a duplicate
                if(!duplicate(fingers,new PVector(savedX,savedY))){
                  fingers[pointer] = new PVector(savedX,savedY);
                  pointer++;
                }
              }
              
              white=false;
            }
            black=true;
            
            
          }
        }
      }
      
    }
    
    return fingers;
  }
  
  //Assumes finger is non-null
  boolean duplicate(PVector[] fingers, PVector finger){
    //Might want to make this measure based on handLength or sumting
    int measure = 10;
    boolean duplicate = false;
    for(int i = 0; i<fingers.length; i++){
      if(fingers[i] !=null){
        if(fingers[i].x+measure>finger.x && fingers[i].x-measure<finger.x){
          if(fingers[i].y+measure>finger.y && fingers[i].y-measure<finger.y){
            duplicate=true;
          }
        }
      }
    }
    if(thumb!=null){
      if(thumb.x+measure>finger.x && thumb.x-measure<finger.x){
        if(thumb.y+measure>finger.y && thumb.y-measure<finger.y){
          duplicate=true;
        }
      }
    }
    
    if(pinky!=null){
      if(pinky.x+measure>finger.x && pinky.x-measure<finger.x){
        if(pinky.y+measure>finger.y && thumb.y-measure<finger.y){
          duplicate=true;
        }
      }
    }
    
    
    return duplicate;
  }
  
  /**
  * Determines if a past in Vector could be a thumb based on how quickly it hits black pixels on either side
  *
  */
  public boolean thumbChecker(PVector possibleThumb){
    if(hand!=null && possibleThumb!=null){
      if(thumbHeightChecker(possibleThumb) && thumbWidthChecker(possibleThumb)){
        return true;
      }
      else{
        return false;
      }
    }
    else{
      return false;
    }
  }
  
  /**
  * Based on formula found here: 
  * http://local.wasp.uwa.edu.au/~pbourke/geometry/pointline/
  *
  * P3: possibleThumb
  * P2: hand
  * P1: wrist
  */
  boolean thumbHeightChecker(PVector possibleThumb){
    
    float u = (possibleThumb.x-wrist.x)*(hand.x-wrist.x)+(possibleThumb.y-wrist.y)*(hand.y-wrist.y);
    
    u=u/(handLength*handLength);
    
    
    float closestXOnLine = wrist.x+u*(hand.x-wrist.x);
    float closestYOnLine = wrist.y+u*(hand.y=wrist.y);
    
    PVector closestPnt = new PVector(closestXOnLine,closestYOnLine);
    
    float thumbHeight = PVector.sub(possibleThumb,closestPnt).mag();
    
    if(thumbHeight>(handLength/3.0f) && thumbHeight<handLength*1.5){
      return true;
    }
    else{
      return false;
    }
  }
  
  //Checks if it's the right width
  boolean thumbWidthChecker(PVector possibleThumb){
     float thumbWidth = handLength/4;
    PVector thumbWrist = PVector.sub(possibleThumb,wrist);
    
    PVector leftPerp = new PVector(thumbWrist.y,-1*thumbWrist.x);
    PVector rightPerp = new PVector(-1*thumbWrist.y, thumbWrist.x);
    
    boolean left=false;
    boolean right=false;
    
    leftPerp.normalize();
    rightPerp.normalize();
    
    PVector leftIncrement = new PVector(leftPerp.x, leftPerp.y);
    PVector rightIncrement = new PVector(rightPerp.x, rightPerp.y);
    
    leftPerp.add(possibleThumb);
    rightPerp.add(possibleThumb);
    
    PVector leftCheck = PVector.sub(leftPerp, possibleThumb);
    
    
    while(leftCheck.mag()<thumbWidth){
      int index = (int)(leftPerp.x+leftPerp.y*w);
      if(index>0 && index<out.pixels.length){
        if(brightness(out.pixels[index])==0){
          left=true;
        }
      }
      
      leftPerp.add(leftIncrement);
      leftCheck = PVector.sub(leftPerp, possibleThumb);
    }
    
    PVector rightCheck = PVector.sub(rightPerp, possibleThumb);
    
    while(rightCheck.mag()<thumbWidth){
      int index = (int)(rightPerp.x+rightPerp.y*w);
      if(index>0 && index<out.pixels.length){
        if(brightness(out.pixels[index])==0){
          right=true;
        }
      }
      
      rightPerp.add(rightIncrement);
      rightCheck = PVector.sub(rightPerp, possibleThumb);
    }
    
    //Has to be both to be tue
    boolean answer = left && right;
    
    return answer;
  }
  
  /**
  * Figures out if pixel is in bounding box, if so, sets to black. 
  *
  *
  */
  void blackenPalm(){
     for(int y=0; y<out.height; y++){
      for(int x=0; x<out.height; x++){
        int index = (int)x+(int)y*out.width;
        
        if(index>0 && index<out.pixels.length){
          //Checks if in Palm box, sets to black if so
          if(bBox.contains(0.0f,0.0f,x,y)){
            out.pixels[index]=color(0,0,0);
            
          }
          //Get rid of the arm too, why not?
          else if(green(out.pixels[index])==255 && red(out.pixels[index])==0){
            out.pixels[index]=color(0,0,0);
          }
          
        }
        
        
      }
    }
  }
}

