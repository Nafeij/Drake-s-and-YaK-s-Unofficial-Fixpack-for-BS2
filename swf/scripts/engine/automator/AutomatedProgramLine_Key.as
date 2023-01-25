package engine.automator
{
   import engine.core.cmd.IKeyBinder;
   import flash.ui.Keyboard;
   
   public class AutomatedProgramLine_Key extends AutomatedProgramLine
   {
       
      
      public var keyname:String;
      
      public var keyCode:uint;
      
      public var keybinder:IKeyBinder;
      
      public var ctrlKey:Boolean;
      
      public var altKey:Boolean;
      
      public var shiftKey:Boolean;
      
      public var down:Boolean;
      
      public var up:Boolean;
      
      public function AutomatedProgramLine_Key(param1:AutomatedProgram, param2:int, param3:String, param4:Array)
      {
         var _loc7_:String = null;
         super(param1,param2,param3,param4);
         this.keybinder = param1.context.keybinder;
         var _loc5_:String = String(param4[1]);
         _loc5_ = _loc5_.toUpperCase();
         this.down = _loc5_ == "DOWN" || _loc5_ == "CLICK";
         this.up = _loc5_ == "UP" || _loc5_ == "CLICK";
         if(!this.down && !this.up)
         {
            this.down = this.up = true;
         }
         else
         {
            param4.shift();
         }
         this.keyname = param4[1];
         this.keyCode = Keyboard[this.keyname];
         var _loc6_:int = 2;
         while(_loc6_ < param4.length)
         {
            _loc7_ = String(param4[_loc6_]);
            _loc7_ = _loc7_.toUpperCase();
            this.ctrlKey = this.ctrlKey || _loc7_ == "CTRL";
            this.altKey = this.altKey || _loc7_ == "ALT";
            this.shiftKey = this.shiftKey || _loc7_ == "SHIFT";
            _loc6_++;
         }
      }
      
      override protected function handleExecuted() : void
      {
         if(this.down)
         {
            this.keybinder.performKeyDown(this.ctrlKey,this.altKey,this.shiftKey,this.keyCode);
         }
         if(this.up)
         {
            this.keybinder.performKeyUp(this.keyCode);
         }
         finish();
      }
   }
}
