package engine.core.cmd
{
   import engine.core.gp.GpBinder;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.gui.page.PageManagerAdapter;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   
   public class KeyBinder implements IKeyBinder
   {
      
      public static var keybinder:KeyBinder;
       
      
      private var _stage:Stage;
      
      private var binds:Dictionary;
      
      private var bindsGroup:Dictionary;
      
      private var disabledGroups:Dictionary;
      
      private var cmder:Cmder;
      
      public var logger:ILogger;
      
      private var _disabledAllBindsGroups:Boolean;
      
      public var keysDown:Dictionary;
      
      public function KeyBinder(param1:Cmder, param2:ILogger)
      {
         this.binds = new Dictionary();
         this.bindsGroup = new Dictionary();
         this.disabledGroups = new Dictionary();
         this.keysDown = new Dictionary();
         super();
         this.cmder = param1;
         this.logger = param2;
         KeyBinder.keybinder = this;
      }
      
      public function cleanup() : void
      {
         this.stage = null;
      }
      
      public function getDebugDump(param1:ILogger) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Vector.<Cmd> = null;
         var _loc5_:String = null;
         var _loc6_:Cmd = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         param1.info("BINDS:");
         for(_loc2_ in this.binds)
         {
            _loc4_ = this.binds[_loc2_];
            if(Boolean(_loc4_) && _loc4_.length > 0)
            {
               _loc5_ = null;
               param1.info("   " + StringUtil.padRight(_loc2_," ",20) + " " + StringUtil.padRight(_loc5_," ",20));
               for each(_loc6_ in _loc4_)
               {
                  _loc7_ = String(this.bindsGroup[_loc6_]);
                  _loc8_ = "      " + _loc6_.name;
                  if(_loc7_)
                  {
                     _loc8_ += " (GROUP " + _loc7_ + ")";
                  }
                  param1.info(_loc8_);
               }
            }
         }
         param1.info("DISABLED GROUPS:");
         for(_loc3_ in this.disabledGroups)
         {
            param1.info("   " + _loc3_);
         }
      }
      
      private function findBoundCmd(param1:String) : Cmd
      {
         var _loc3_:int = 0;
         var _loc4_:Cmd = null;
         var _loc5_:String = null;
         var _loc2_:Vector.<Cmd> = this.binds[param1];
         if(_loc2_)
         {
            _loc3_ = int(_loc2_.length - 1);
            while(_loc3_ >= 0)
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = String(this.bindsGroup[_loc4_]);
               if(!(_loc5_ in this.disabledGroups))
               {
                  if(!_loc5_ || !this._disabledAllBindsGroups)
                  {
                     return _loc4_;
                  }
               }
               _loc3_--;
            }
         }
         return null;
      }
      
      private function _bindBinding(param1:String, param2:Cmd, param3:String) : void
      {
         if(param1 in this.binds)
         {
         }
         this.bindsGroup[param2] = param3;
         var _loc4_:Vector.<Cmd> = this.binds[param1];
         if(!_loc4_)
         {
            _loc4_ = new Vector.<Cmd>();
            this.binds[param1] = _loc4_;
         }
         _loc4_.push(param2);
      }
      
      public function disableAllBindsGroups() : void
      {
         this._disabledAllBindsGroups = true;
      }
      
      public function enableAllBindsGroups() : void
      {
         this._disabledAllBindsGroups = false;
      }
      
      public function bind(param1:Boolean, param2:Boolean, param3:Boolean, param4:uint, param5:Cmd, param6:String, param7:Cmd = null) : void
      {
         var _loc8_:String = KeyBinderUtil.makeBinding(param1,param2,param3,param4);
         this._bindBinding(_loc8_,param5,param6);
         if(param7)
         {
            this.bindUp(param4,param7,param6);
         }
      }
      
      public function bindUp(param1:uint, param2:Cmd, param3:String) : void
      {
         var _loc4_:String = KeyBinderUtil.makeBindingUp(param1);
         this._bindBinding(_loc4_,param2,param3);
      }
      
      public function disableBindsFromGroup(param1:String) : void
      {
         this.disabledGroups[param1] = true;
      }
      
      public function enableBindsFromGroup(param1:String) : void
      {
         delete this.disabledGroups[param1];
      }
      
      public function unbind(param1:Cmd) : void
      {
         var _loc2_:String = null;
         var _loc3_:Vector.<Cmd> = null;
         var _loc4_:int = 0;
         for(_loc2_ in this.binds)
         {
            _loc3_ = this.binds[_loc2_];
            if(_loc3_)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  if(_loc3_[_loc4_] == param1)
                  {
                     _loc3_.splice(_loc4_,1);
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
      
      public function performKeyDown(param1:Boolean, param2:Boolean, param3:Boolean, param4:uint) : Cmd
      {
         this.keysDown[param4] = true;
         var _loc5_:String = KeyBinderUtil.makeBinding(param1,param2,param3,param4);
         var _loc6_:Cmd = this.findBoundCmd(_loc5_);
         if(_loc6_ != null)
         {
            this.cmder.execute(_loc6_,null,1);
         }
         return _loc6_;
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            param1.preventDefault();
         }
         if(PageManagerAdapter.IS_LOADING || GpBinder.DISALLOW_INPUT_DURING_LOAD)
         {
            return;
         }
         var _loc2_:Cmd = this.performKeyDown(param1.ctrlKey,param1.altKey,param1.shiftKey,param1.keyCode);
         if(_loc2_ != null)
         {
            param1.preventDefault();
            param1.stopImmediatePropagation();
         }
      }
      
      public function performKeyUp(param1:uint) : Cmd
      {
         delete this.keysDown[param1];
         var _loc2_:String = KeyBinderUtil.makeBindingUp(param1);
         var _loc3_:Cmd = this.findBoundCmd(_loc2_);
         if(_loc3_ != null)
         {
            this.cmder.execute(_loc3_,null,1);
         }
         this.handleKeyDown(param1);
         return _loc3_;
      }
      
      private function keyUpHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ESCAPE)
         {
            param1.preventDefault();
         }
         if(PageManagerAdapter.IS_LOADING || GpBinder.DISALLOW_INPUT_DURING_LOAD)
         {
            return;
         }
         var _loc2_:Cmd = this.performKeyUp(param1.keyCode);
         if(_loc2_ != null)
         {
            param1.preventDefault();
            param1.stopImmediatePropagation();
         }
      }
      
      protected function handleKeyDown(param1:int) : void
      {
      }
      
      public function get stage() : Stage
      {
         return this._stage;
      }
      
      public function set stage(param1:Stage) : void
      {
         if(this._stage)
         {
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
            this._stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
         }
         this._stage = param1;
         if(this._stage)
         {
            this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,true,100);
            this._stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler,true,100);
         }
      }
   }
}
