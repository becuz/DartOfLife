import 'dart:html';
import 'dart:math';

final CanvasRenderingContext2D context = (querySelector("#canvas") as CanvasElement).context2D;
final InputElement slider = querySelector("#slider");
final Element btnRun = querySelector("#run");
final Element btnStep = querySelector("#step");
final Element btnLoop = querySelector("#loop");
final Element btnRandom = querySelector("#random");
final Element notes = querySelector("#notes");

final int MAX_PX = 600;  //pixel size of the canvas side

int sideSize = 10;  //num of cells per canvas side
int cellSize = 10;  //pixel size of the cell side
Map cells;          //matrix of boolean cells
bool isLooping = false;

void main() { 
  //slider.onChange.listen((e) => drawGrid());
  var canvas = querySelector("#canvas");
  canvas.onClick.listen((e) => clickedCell(e));
  
  btnRun.onClick.listen((e) => run());
  btnRandom.onClick.listen((e) => randomize());
  btnStep.onClick.listen((e) => step());
  btnLoop.onClick.listen((e) => loop());
  run();
}


/**
* Create a boolean map value for each cell.
*/
void initGame() {
  sideSize = int.parse(slider.value);
  cellSize = MAX_PX ~/ sideSize;
  cells = new Map();
  for (int column = 0; column < sideSize; column++) {
    cells[column] = new Map();
    for (int row = 0; row < sideSize; row++) {
      cells[column][row] = false;
    }
  }
}

/**
 * Set some random alive cells
 */
void randomize() {
  var rng = new Random();
  for (int column = 0; column < sideSize; column++) {
    for (int row = 0; row < sideSize; row++) {
      cells[column][row] = rng.nextBool();
    }
  }
  step();
}

/**
 * Reset the game with all dead cells
 */
void run(){
  initGame();
  drawGrid();
  drawCells();
}

/**
 * Perform a single step
 */
void step(){
  drawGrid();
  updateCells();
  drawCells();
}

/**
 * Toggle the loop
 */
void loop(){
  isLooping = !isLooping;
  if (isLooping) window.animationFrame.then(doLoop);
}

/**
 * Loop the game
 */
void doLoop(num delta){
  step();
  if (isLooping) window.animationFrame.then(doLoop);
}

/**
* Conway's Game of Life rules:
* 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
* 2. Any live cell with two or three live neighbours lives on to the next generation.
* 3. Any live cell with more than three live neighbours dies, as if by overcrowding.
* 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
* 
* TODO make if immutable and functional
* 
*/
void updateCells(){
  //copy cells
  Map cellsCopy = new Map();
  for (int column = 0; column < sideSize; column++) {
    cellsCopy[column] = new Map();
    for (int row = 0; row < sideSize; row++) {
      cellsCopy[column][row] = cells[column][row];
    }
  }
  
  //compute new status in cellsCopy
  for (int column = 0; column < sideSize; column++) {
    for (int row = 0; row < sideSize; row++) {
      var aliveNeighbours = getAliveNeighbour(column, row);
      if (cells[column][row]){              //if alive
        if (aliveNeighbours < 2){           //0 or 1 => die
          cellsCopy[column][row] = false;
        } else if (aliveNeighbours <= 3){   // 2 or 3 => remains alive
        } else {                            //more than 3  => die
          cellsCopy[column][row] = false;
        }
      } else {                              //if dead
        if (aliveNeighbours == 3){          //exactly 3 => resurrect
          cellsCopy[column][row] = true;
        }
      }
    }
  }
  
  //use cellsCopy
  for (int column = 0; column < sideSize; column++) {
    cells[column] = new Map();
    for (int row = 0; row < sideSize; row++) {
      cells[column][row] = cellsCopy[column][row];
    }
  }
}

/**
 * Returns the number of alive neighbours 
 */
int getAliveNeighbour(int column, int row){
  int num = 0;
  for (int i = column-1; i <= column+1; i++) {
    for (int j = row-1; j <= row+1; j++) {
      if (i!=column || j!=row) {
        if (i>-1 && i<sideSize && j>-1 && j<sideSize && cells[i][j]) num++;
      }
    }
  }
  return num;
}

/**
 * Draws the alive cells
 */
void drawCells(){
  for (int column = 0; column < sideSize; column++) {
    for (int row = 0; row < sideSize; row++) {
      if (cells[column][row]) {
        
        context.rect(column * cellSize, row * cellSize, cellSize, cellSize);
      }
    }
  }
  context.fillStyle = '#0099FF';
  context.fill();
  context.stroke();
}

/**
 * Draws the grid
 */
void drawGrid(){
  context.clearRect(0, 0, MAX_PX, MAX_PX);
  context.beginPath();
  
  int max = sideSize * cellSize;
  for (var column = 0; column <= sideSize; column++) {
      context.moveTo(column * cellSize, 0);
      context.lineTo(column * cellSize, max);
  }
  for (var row = 0; row <= sideSize; row++) {
    context.moveTo(0, row * cellSize);
    context.lineTo(max, row * cellSize);
  }
  context.lineWidth = 1;
  context.lineCap = 'round';
  context.stroke();
  context.closePath();

  notes.text = "${sideSize} x ${sideSize} cells. Size grid ${max}. Size cell ${cellSize}px";
}

/**
 * Kill or resurrect the clicked cell
 */
void clickedCell(MouseEvent event) {
    int column = event.offset.x ~/ cellSize;
    int row = event.offset.y ~/ cellSize;
    cells[column][row] = ! cells[column][row];
    drawGrid();
    drawCells();
}
