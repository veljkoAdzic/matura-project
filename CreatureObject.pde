float breedingChance = 0.005;   //Chance of repruduction in %
float steeringStrenght = 0.05;  //Strength of applied steering in %
float eatableSize = 0.95;        //% of how smaller creature can be canibalised

//Minimum and maximum ranges
float[] capSight = {25, 150};
float[] capSize =  {10, 150};
float[] capSpeed = {1 , 5 };
//~

//maximum energy possible
float maxEnergy = ( capSight[1] + pow(capSize[1], 3) * pow(capSpeed[1], 2) ) / 2;

class Creature {
  //~~~~~~~~~~~~~~~~~~~~~ Setup code ~~~~~~~~~~~~~~~~~~~~~
  
  boolean alive;
  float sight, size, speed, energy, fullEnergy;
  float[] DNA = {0.0, 0.0, 0.0};
  int breedingCooldown;
  
  PVector pos, vel, acc, wonder;
  
  //Constructor
  Creature(float _x, float _y, float _size, float _sight, float _speed){
    alive = true;
    breedingCooldown = 0;
    
    size = constrain(_size, capSize[0], capSize[1]);
    sight = size + constrain(_sight, capSight[0], capSight[1]);
    speed = constrain(_speed, capSpeed[0], capSpeed[1]);
    
    energy = ( sight + pow(size, 3) * pow(speed, 2) ) / 2;
    fullEnergy = energy;
    
    DNA[0] = size;
    DNA[1] = sight;
    DNA[2] = speed;
    
    
    pos = new PVector(_x, _y);
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    
    wonder = new PVector( random(width), random(height) );
  }
  //~
  
  //Overloaded constructor for random pos, size, speed, sight and speed
  Creature(){
    alive = true;
    breedingCooldown = 0;
    
    size = random(capSize[0], capSize[1]);
    sight = size + random(capSight[0], capSight[1]);
    speed = random(capSpeed[0], capSpeed[1]);
    
    energy = ( sight + pow(size, 3) * pow(speed, 2) ) / 2;
    fullEnergy = energy;
    
    DNA[0] = size;
    DNA[1] = sight;
    DNA[2] = speed;
    
    
    pos = new PVector( random(width), random(height) );
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    
    wonder = new PVector( random(width), random(height) );
  }
  //~
  
  //~~~~~~~~~~~~~~~~~~~~~ Main code ~~~~~~~~~~~~~~~~~~~~~
  
  //Find the best target
  PVector desire(){
    PVector target = null;
    float ratio = -100000;
    
    //~loop thru food and see which is the best target
    for(int i = food.size() - 1; i >= 0; i-- ){
      if(food.get(i).pos.dist(pos) <= sight){                        //check if food in sight
        if(ratio < food.get(i).energy / food.get(i).pos.dist(pos)){  //check if food is better than previous
          ratio = floor(food.get(i).energy / food.get(i).pos.dist(pos));    //save new ratio
          target = food.get(i).pos;                                  //save new target
        }
      }
    }
    //~~
    
    //~loop thru creatures and see if and which is the best target
    for(int i = creatures.size() - 1; i >= 0; i-- ){
      if(creatures.get(i).pos.dist(pos) <= sight &&     //check if creature in sight
         creatures.get(i) != this &&                    //check if creature is not self
         creatures.get(i).size < size * eatableSize){   //check if creature small enough
           
        if(ratio < creatures.get(i).energy / creatures.get(i).pos.dist(pos)){  //check of creature is better than previous
          ratio = floor(creatures.get(i).energy / creatures.get(i).pos.dist(pos));    //save new ratio
          target = creatures.get(i).pos;                   //save new target
        }
      }
    }
    //~~
    
    //~if wonder is reached set new wonder point
    if(wonder.dist(pos) < 10){
      wonder.x = random(width);
      wonder.y = random(height);
    }
    //~~
    
    target = (target == null) ? wonder : target;  //if no target seek wonder
    
    return PVector.sub(target, pos);  //return desired target
  }
  //~
  
  //eat all meals
  void eat(){
    //~loop thru food and see which is the best target
    for(int i = food.size() - 1; i >= 0; i-- ){
      if(food.get(i).pos.dist(pos) <= size/4){
          energy += food.get(i).energy;
          food.remove(i);
      }
    }
    //~~
    
    //~loop thru creatures and see if and which is the best target
    for(int i = creatures.size() - 1; i >= 0; i--){
      if(creatures.get(i) != this &&                      //check if creature in sight
         //creatures.get(i).age >= 5 * frameRate &&         //do not eat the young
         creatures.get(i).pos.dist(pos) <= size/4 &&      //check if creature close enough
         creatures.get(i).size < size * eatableSize){     //check if creature small enough
          energy += creatures.get(i).energy;
          creatures.remove(i);
      }
    }
    //~~
  }
  //~
  
  //Steer towards target
  void steer(){
   PVector desire = desire();  //get desired target
   desire.setMag(speed);       //set the the magnitute of vector pointing towards desire
   
   PVector steer = PVector.sub(desire, vel);  //calculate the seering vector towards target
   steer.mult(steeringStrenght);              //how much does it steer
   acc.add(steer);                            //apply the steering force
  }
  //~
  
  //Update the creature
  void update(){
    if(alive){
      //~Autominous agent code
      steer();  //steer towards target
      
      vel.add(acc);      //update velocity
      vel.limit(speed);  //limit velocity
      pos.add(vel);      //update position
      acc.mult(0);       //reset acceleration
      //~
      
      //~Living code
      breedingCooldown++;
      
      breed();
      
      //use energy
      energy -= round( (sight + 
                        size*2 + 
                        pow(speed, 2) +
                        pow(creatures.size(), 3)*2 ) / 5 );
      
      alive = (energy > 0);
      
      //~~
    }
  }
  //~
  
  //Reproduction
  void breed(){
    float[] newDNA = {0.0, 0.0, 0.0};
    if(breedingCooldown >= 10 * frameRate && 
       energy >= 9000 &&
       random(1) < breedingChance){
        newDNA[0] = constrain(floor(DNA[0] + DNA[0] * random(-0.05, 0.05)), capSize[0], capSize[1]);
        newDNA[1] = constrain(floor(DNA[1] + DNA[1] * random(-0.05, 0.05)), capSight[0], capSight[1]);
        newDNA[2] = constrain(floor(DNA[2] + DNA[2] * random(-0.05, 0.05)), capSpeed[0], capSpeed[1]);
        
        energy -= 10000;
        
        breedingCooldown = 0;
        
        creatures.add( new Creature(pos.x + random(-size, size), pos.y  + random(-size, size), newDNA[0], newDNA[1], newDNA[2]) );
    }
  }
  //~
  
  //Death
  void die(){
    int nof = floor(size/5);
    
    for(int i = 0; i < nof; i++){      
      if(i <= nof * 0.7){  //70% will be good food
        food.add( new Food( pos.x + random(-size/2, size/2),
                              pos.y + random(-size/2, size/2), 
                              map(fullEnergy, 0, maxEnergy, 20, 50) ) );
      } else {             //30% will be bad
        food.add( new Food( pos.x + random(-size/2, size/2),
                              pos.y + random(-size/2, size/2), 
                              map(fullEnergy, 0, maxEnergy, -30, -1) ) );
      }
    }
    
    creatures.remove(this);
  }
  //~
  
  //~~~~~~~~~~~~~~~~~~~~~ Misc code ~~~~~~~~~~~~~~~~~~~~~
  
  //display the creature
  void show(){
    push();
    
    //~calculate colour based on energy
    color fillCol = lerpColor( color(220, 10, 0, 150),
                                 color(220, 220, 0, 150),
                                 map( constrain(energy, 0, fullEnergy), 
                                      0, fullEnergy, 0, 1 )
                               );
    
    color strokeCol = lerpColor( color(220, 10, 0, 200),
                                   color(230, 220, 0, 250),
                                   map( constrain(energy, 0, fullEnergy),
                                        0, fullEnergy, 0, 1 )
                                 );
    //~~
    
    stroke(strokeCol);           //set stroke colour
    strokeWeight(3);             //set stroke size
    fill(fillCol);               //set fill colour
    circle(pos.x, pos.y, size);  //draw the creature
    
    pop();
  }
  //~
}
