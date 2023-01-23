package engine.core.gp
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.Cmder;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGpBitmap;
   import engine.gui.page.PageManagerAdapter;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class GpBinder extends EventDispatcher
   {
      
      public static var gpbinder:GpBinder = new GpBinder(null,null);
      
      public static const EVENT_LAYER:String = "GpBinder.EVENT_LAYER";
      
      public static var ALLOW_INPUT_DURING_LOAD:Boolean;
      
      public static var DISALLOW_INPUT_DURING_LOAD:Boolean = false;
       
      
      private var cmder:Cmder;
      
      private var logger:ILogger;
      
      private var binds:Dictionary;
      
      private var bindsGroup:Dictionary;
      
      private var disabledGroups:Dictionary;
      
      public var layers:Vector.<Object>;
      
      public function GpBinder(param1:Cmder, param2:ILogger)
      {
         this.binds = new Dictionary();
         this.bindsGroup = new Dictionary();
         this.disabledGroups = new Dictionary();
         this.layers = new Vector.<Object>();
         super();
         this.cmder = param1;
         this.logger = param2;
         gpbinder = this;
      }
      
      public function elevate(param1:Cmd) : void
      {
         var _loc2_:* = null;
         var _loc3_:Vector.<GpBinderConditionalCmd> = null;
         var _loc4_:GpBinderConditionalCmd = null;
         for(_loc2_ in this.binds)
         {
            _loc3_ = this.binds[_loc2_];
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_.cmd == param1)
               {
                  _loc4_.id = ++GpBinderConditionalCmd.last_id;
               }
            }
         }
      }
      
      public function createLayer(param1:String) : int
      {
         ++GpBinderConditionalCmd.last_id;
         this.layers.push({
            "id":GpBinderConditionalCmd.last_id,
            "name":param1
         });
         if(GpSource.GP_DEBUG)
         {
            this.logger.i("GP","GpBinder.createLayer " + GpBinderConditionalCmd.last_id + " name=" + param1);
         }
         dispatchEvent(new Event(EVENT_LAYER));
         return GpBinderConditionalCmd.last_id;
      }
      
      public function removeLayer(param1:int) : void
      {
         var _loc3_:Object = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.layers.length)
         {
            _loc3_ = this.layers[_loc2_];
            if(_loc3_.id == param1)
            {
               this.layers.splice(_loc2_,1);
               if(GpSource.GP_DEBUG)
               {
                  this.logger.i("GP","GpBinder.removeLayer " + param1 + " name=" + _loc3_.name);
               }
               dispatchEvent(new Event(EVENT_LAYER));
               break;
            }
            _loc2_++;
         }
      }
      
      private function findBoundCmd(param1:GpControlButton, param2:Cmd = null) : GpBinderConditionalCmd
      {
         var _loc5_:int = 0;
         var _loc6_:GpBinderConditionalCmd = null;
         var _loc7_:String = null;
         var _loc3_:Vector.<GpBinderConditionalCmd> = this.binds[param1];
         var _loc4_:int = this.topLayer;
         if(_loc3_)
         {
            _loc5_ = _loc3_.length - 1;
            while(_loc5_ >= 0)
            {
               _loc6_ = _loc3_[_loc5_];
               if(!(Boolean(param2) && _loc6_.cmd != param2))
               {
                  if(!_loc6_.cmd.global && _loc6_.id <= _loc4_)
                  {
                     if(GpSource.GP_DEBUG)
                     {
                        this.logger.i("GP","GpBinder id=" + this.lastCmdId + " binding=" + param1 + " LAYER-SKIPPING " + _loc6_);
                     }
                  }
                  else if(!_loc6_.cmd.enabled)
                  {
                     if(GpSource.GP_DEBUG)
                     {
                        this.logger.i("GP","GpBinder id=" + this.lastCmdId + " binding=" + param1 + " ENABLED-SKIPPING " + _loc6_);
                     }
                  }
                  else
                  {
                     _loc7_ = this.bindsGroup[_loc6_];
                     if(!(_loc7_ in this.disabledGroups))
                     {
                        return _loc6_;
                     }
                     if(GpSource.GP_DEBUG)
                     {
                        this.logger.i("GP","GpBinder id=" + this.lastCmdId + " binding=" + param1 + " GROUP-SKIPPING " + _loc6_);
                     }
                  }
               }
               _loc5_--;
            }
         }
         return null;
      }
      
      public function wrap(param1:Function) : Function
      {
         var f:Function = param1;
         return function(param1:CmdExec):void
         {
            f();
         };
      }
      
      public function bind(param1:GpControlButton, param2:Cmd, param3:String = "", param4:Boolean = false, param5:Number = -100000, param6:Number = 100000) : GpBinderConditionalCmd
      {
         if(param1 in this.binds)
         {
         }
         this.bindsGroup[param2] = param3;
         var _loc7_:Vector.<GpBinderConditionalCmd> = this.binds[param1];
         if(!_loc7_)
         {
            _loc7_ = new Vector.<GpBinderConditionalCmd>();
            this.binds[param1] = _loc7_;
         }
         var _loc8_:GpBinderConditionalCmd = new GpBinderConditionalCmd(param2,param4 ? param1 : null,param5,param6);
         _loc7_.push(_loc8_);
         return _loc8_;
      }
      
      public function bindValue(param1:GpControlButton, param2:Cmd, param3:String, param4:Boolean, param5:Number) : GpBinderConditionalCmd
      {
         return this.bind(param1,param2,param3,param4,param5,param5);
      }
      
      public function bindPress(param1:GpControlButton, param2:Cmd, param3:String = null, param4:Boolean = false) : GpBinderConditionalCmd
      {
         return this.bind(param1,param2,param3,param4,1,1);
      }
      
      public function getGpBmp(param1:GpControlButton, param2:Cmd) : GuiGpBitmap
      {
         var _loc3_:GpBinderConditionalCmd = this.findBoundCmd(param1,param2);
         return !!_loc3_ ? _loc3_.gpbmp : null;
      }
      
      public function disableBindsFromGroup(param1:String) : void
      {
         this.disabledGroups[param1] = true;
      }
      
      public function enableBindsFromGroup(param1:String) : void
      {
         delete this.disabledGroups[param1];
      }
      
      public function get lastCmdId() : int
      {
         return GpBinderConditionalCmd.last_id;
      }
      
      public function get topLayer() : int
      {
         var _loc1_:Object = this.layers.length > 0 ? this.layers[this.layers.length - 1] : null;
         return !!_loc1_ ? int(_loc1_.id) : -1;
      }
      
      public function unbind(param1:Cmd) : void
      {
         var _loc2_:* = null;
         var _loc3_:Vector.<GpBinderConditionalCmd> = null;
         var _loc4_:int = 0;
         var _loc5_:GpBinderConditionalCmd = null;
         for(_loc2_ in this.binds)
         {
            _loc3_ = this.binds[_loc2_];
            if(_loc3_)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  _loc5_ = _loc3_[_loc4_];
                  if(_loc5_.cmd == param1)
                  {
                     _loc3_.splice(_loc4_,1);
                     _loc5_.cleanup();
                  }
                  else
                  {
                     _loc4_++;
                  }
               }
            }
         }
         delete this.bindsGroup[param1];
      }
      
      public function handleGpControl(param1:GpControlButton, param2:Number) : void
      {
         if(this.logger.isDebugEnabled && GpSource.GP_DEBUG)
         {
            this.logger.d("GP","GpBinder " + param1 + " " + param2);
         }
         var _loc3_:GpBinderConditionalCmd = this.findBoundCmd(param1);
         if(GpSource.GP_DEBUG)
         {
            this.logger.i("GP","GpBinder id=" + this.lastCmdId + " binding=" + param1 + " / " + param2.toFixed(2) + " -> " + _loc3_);
         }
         if(_loc3_ != null && (!PageManagerAdapter.IS_LOADING && !GpBinder.DISALLOW_INPUT_DURING_LOAD || GpBinder.ALLOW_INPUT_DURING_LOAD))
         {
            _loc3_.execute(this.cmder,param2,this.logger);
         }
      }
      
      public function getDebugDump() : String
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:Object = null;
         var _loc5_:GpControlButton = null;
         var _loc6_:Vector.<GpBinderConditionalCmd> = null;
         var _loc7_:GpBinderConditionalCmd = null;
         var _loc8_:String = null;
         var _loc1_:* = "";
         _loc1_ += "BINDS:\n";
         for(_loc2_ in this.binds)
         {
            _loc5_ = _loc2_ as GpControlButton;
            _loc6_ = this.binds[_loc2_];
            if(Boolean(_loc6_) && _loc6_.length > 0)
            {
               _loc1_ += "   " + StringUtil.padRight(_loc5_.name," ",20) + "\n";
               for each(_loc7_ in _loc6_)
               {
                  _loc8_ = this.bindsGroup[_loc7_.cmd];
                  _loc1_ += "      " + _loc7_;
                  if(_loc8_)
                  {
                     _loc1_ += " (GROUP " + _loc8_ + ")\n";
                  }
                  else
                  {
                     _loc1_ += "\n";
                  }
               }
            }
         }
         _loc1_ += "DISABLED GROUPS:\n";
         for(_loc3_ in this.disabledGroups)
         {
            _loc1_ += "   " + _loc3_ + "\n";
         }
         _loc1_ += "LAYERS:\n";
         for each(_loc4_ in this.layers)
         {
            _loc1_ += "   " + StringUtil.padLeft(_loc4_.id.toString()," ",4) + " " + _loc4_.name + "\n";
         }
         return _loc1_;
      }
   }
}
