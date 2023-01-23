package game.cfg
{
   import engine.automator.AutomatedProgram;
   import engine.automator.AutomatedProgramContext;
   import engine.automator.EngineAutomator;
   import engine.core.logging.ILogger;
   
   public class GameAutomator
   {
       
      
      private var context:AutomatedProgramContext;
      
      private var program:AutomatedProgram;
      
      public var logger:ILogger;
      
      public var config:GameConfig;
      
      public var shell:GameAutomatorShell;
      
      public function GameAutomator(param1:GameConfig, param2:ILogger)
      {
         super();
         this.logger = param2;
         this.config = param1;
         this.context = new GameAutomatedProgramContext(param1);
         EngineAutomator.init(this.context,param2);
         this.shell = new GameAutomatorShell(this);
         param1.shell.addShell("program",this.shell);
      }
      
      public function runScript(param1:String) : void
      {
         this.program = new AutomatedProgram(this.context);
         this.program.parse(param1);
         EngineAutomator.instance.runProgramScript(this.program);
      }
      
      public function update() : void
      {
         EngineAutomator.update();
      }
      
      public function stop() : void
      {
         EngineAutomator.instance.stop();
      }
      
      public function list() : void
      {
         EngineAutomator.instance.list();
      }
      
      public function where() : void
      {
         EngineAutomator.instance.where();
      }
   }
}
