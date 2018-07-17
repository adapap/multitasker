void calculateWater() {
    float angleRate = 0.25;
    float waterRate = 35;
    int waterPointsNeeded = 500;
    int score = gameState.get("score");
    int waterStage = gameState.get("water");
    // Stage 0 - Rotate Down & Spawn Water
    if (waterStage == 0) {
      if (gameAngle < 30) {
        gameAngle += min(angleRate, 30 - gameAngle);
      }
      if (gameAngle == 30) {
        water = new Floor(0, 3.5 * height, 4 * width, 3 * height, true);
        floors.add(water);
        gameState.set("water", 1);
      }
    }
    // Stage 1 - Fill Water
    if (waterStage == 1) {
      water.changeLevel(waterRate, 1);
    }
    // Stage 2 - Flatten & Save Score
    if (waterStage == 2) {
      if (gameAngle > 0) {
        gameAngle -= min(angleRate, gameAngle);
      }
      if (gameAngle == 0 && gameState.get("waterScore") == 0) {
        gameState.set("waterScore", score);
        gameState.set("water", 3);
      }
    }
    // Stage 3 - Underwater Gameplay
    if (waterStage == 3) {
        if (score - gameState.get("waterScore") >= waterPointsNeeded) {
            gameState.set("water", 4);
        }
    }
    // Stage 4 - Rotate Up & Drain
    if (waterStage == 4) {
      if (gameAngle > -30) {
        gameAngle -= min(angleRate, gameAngle + 30);
      }
      if (gameAngle == -30) {
        water.changeLevel(waterRate, -1);
      }
    }
    // Stage 5 - Flatten
    if (waterStage == 5) {
      if (gameAngle < 0) {
        gameAngle += min(angleRate, abs(gameAngle));
      }
      if (gameAngle == 0) {
        gameState.set("water", 6);
      }
    }
    rotateGame(gameAngle);
}