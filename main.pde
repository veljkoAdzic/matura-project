ArrayList<Food> food = new ArrayList<Food>();
ArrayList<Creature> creatures = new ArrayList<Creature>();

void setup(){
  size(1000, 1000);
  
  //pregen food
  for(int i = 0; i < 50; i++)
    food.add( new Food() );
  //~
  
  //pregen creatures
  for(int i =0 ; i < 30; i++)
    creatures.add( new Creature() );
  //~
}

void draw(){
  background(220);
  
  //periodically add food if it's less than 100
  if(frameCount % 10 == 0 && food.size() < 200)
    food.add( new Food() );
  //~
  
  //display the food
  for(int i = food.size() - 1; i >= 0; i--)
    food.get(i).show();
  //~
  
  //removing creatures and optimisation
  if(creatures.size() == 0){
    noLoop();
    println("There are no more creatures");
  }else{
    //~kill dead creatures
    for(int i = creatures.size() - 1; i >= 0; i--){
      if(!creatures.get(i).alive)
      creatures.get(i).die();
    }
    //~~
    
    //~eat meals
    for(int i = creatures.size() - 1; i >= 0; i--)
      creatures.get(i).eat();
    //~~
    
    //~update and draw the creatures
    for(int i = creatures.size() - 1; i >= 0; i--){
      creatures.get(i).update();
      creatures.get(i).show();
    }
    //~
  }
  //~
  
}
