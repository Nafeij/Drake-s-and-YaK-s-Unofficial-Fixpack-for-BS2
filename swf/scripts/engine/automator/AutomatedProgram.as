package engine.automator
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   
   public class AutomatedProgram
   {
       
      
      public var logger:ILogger;
      
      public var programLines:Vector.<AutomatedProgramLine>;
      
      public var context:AutomatedProgramContext;
      
      public function AutomatedProgram(param1:AutomatedProgramContext)
      {
         this.programLines = new Vector.<AutomatedProgramLine>();
         super();
         this.context = param1;
         this.logger = param1.logger;
      }
      
      public function parse(param1:String) : Boolean
      {
         var i:int = 0;
         var line:String = null;
         var apl:AutomatedProgramLine = null;
         var str:String = param1;
         var lines:Array = str.split("\n");
         if(!lines.length)
         {
            throw new ArgumentError("empty program");
         }
         i = 0;
         while(i < lines.length)
         {
            try
            {
               line = lines[i];
               line = StringUtil.trim(line);
               if(line)
               {
                  if(line.charAt(0) != "#")
                  {
                     if(!(line.charAt(0) == "/" && line.length > 1 && line.charAt(1) == "/"))
                     {
                        apl = AutomatedProgramLineCtor.ctor(this,i,line);
                        this.programLines.push(apl);
                     }
                  }
               }
            }
            catch(e:Error)
            {
               logger.e("AUTO","Error on program line " + i + " from zero [" + line + "]\n" + e.getStackTrace());
               return false;
            }
            i++;
         }
         return true;
      }
   }
}
