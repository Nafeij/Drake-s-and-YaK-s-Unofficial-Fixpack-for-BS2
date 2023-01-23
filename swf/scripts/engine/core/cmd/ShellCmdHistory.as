package engine.core.cmd
{
   public class ShellCmdHistory
   {
       
      
      public var cmdlines:Vector.<String>;
      
      public var index:int = -1;
      
      public var cur:String = "";
      
      public function ShellCmdHistory()
      {
         this.cmdlines = new Vector.<String>();
         super();
      }
      
      public function insert(param1:String) : void
      {
         this.cmdlines.push(param1);
         this.index = -1;
         this.cur = "";
      }
      
      public function backward() : String
      {
         if(this.index < 0)
         {
            this.index = this.cmdlines.length - 1;
         }
         else
         {
            this.index = Math.max(0,this.index - 1);
         }
         if(this.index >= 0)
         {
            return this.cmdlines[this.index];
         }
         return this.cur;
      }
      
      public function forward() : String
      {
         if(this.index >= 0)
         {
            this.index = ++this.index;
            if(this.index >= this.cmdlines.length)
            {
               this.index = -1;
            }
         }
         if(this.index >= 0)
         {
            return this.cmdlines[this.index];
         }
         return this.cur;
      }
      
      public function get selected() : String
      {
         if(this.index > 0)
         {
            return this.cmdlines[this.index];
         }
         return this.cur;
      }
   }
}
