float minE = -50,  //minimum energy of food
      maxE = 50;   //maximum energy of food

class Food {
 PVector pos;  //position
 float energy; //energy from food
 
 //Constructor for inputed pos and energy
 Food(float _x, float _y, float _e){
   pos = new PVector(_x, _y);
   
   //capping energy
   energy = constrain(_e, minE, maxE);
 }
 //~
 
 //Overloaded constructor for random pos and energy
 Food(){
  pos = new PVector(random(width), random(height));
  energy = random(-30, maxE);
 }
 //~
 
 //display the food
 void show(){
   push();
   //calculate color based on energy
   color col = lerpColor( color(150, 220, 0),
                          color(200, 10, 0),
                          map(energy, minE, maxE , 0, 1)
                        );
   
   noStroke();
   fill(col);
   circle(pos.x, pos.y, 5);
   pop();
 }
 //~
}
