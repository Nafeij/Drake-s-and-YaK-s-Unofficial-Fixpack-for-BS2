package engine.core.gp
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.Cmder;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   
   public class GpBinderConditionalCmd
   {
      
      public static var last_id:int = 0;
      
      private static const DEFAULT_RANGE:Number = 100000;
       
      
      public var cmd:Cmd;
      
      public var rangeMin:Number;
      
      public var rangeMax:Number;
      
      private var _id:int;
      
      public var gpbmp:GuiGpBitmap;
      
      public function GpBinderConditionalCmd(param1:Cmd, param2:GpControlButton, param3:Number = -100000, param4:Number = 100000)
      {
         this._id = ++last_id;
         super();
         this.cmd = param1;
         this.rangeMin = param3;
         this.rangeMax = param4;
         if(param2)
         {
            this.gpbmp = GuiGp.ctorPrimaryBitmap(param2);
         }
      }
      
      public function cleanup() : void
      {
         if(this.gpbmp)
         {
            if(this.gpbmp.parent)
            {
               this.gpbmp.parent.removeChild(this.gpbmp);
            }
            GuiGp.releasePrimaryBitmap(this.gpbmp);
            this.gpbmp = null;
         }
      }
      
      public function toString() : String
      {
         var _loc1_:* = null;
         if(this.rangeMin == -DEFAULT_RANGE && this.rangeMax == DEFAULT_RANGE)
         {
            _loc1_ = "";
         }
         else if(this.rangeMin == this.rangeMax)
         {
            _loc1_ = "[" + StringUtil.numberWithSign(this.rangeMin,1) + "]";
         }
         else
         {
            _loc1_ = "[" + StringUtil.numberWithSign(this.rangeMin,1) + "," + StringUtil.numberWithSign(this.rangeMax,2) + "]";
         }
         return StringUtil.padLeft(this.id.toString()," ",4) + " " + StringUtil.padLeft(_loc1_," ",20) + " " + this.cmd;
      }
      
      public function execute(param1:Cmder, param2:Number, param3:ILogger) : Boolean
      {
         if(param2 >= this.rangeMin && param2 <= this.rangeMax)
         {
            if(param1)
            {
               if(this.gpbmp)
               {
                  this.gpbmp.pulse();
               }
               param1.execute(this.cmd,null,param2);
            }
            return true;
         }
         if(GpSource.GP_DEBUG)
         {
            param3.i("GP","ConditionalCmd " + this + " RANGE-SKIPPING");
         }
         return false;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
         if(this.gpbmp)
         {
            this.gpbmp.gplayer = param1;
         }
      }
   }
}
