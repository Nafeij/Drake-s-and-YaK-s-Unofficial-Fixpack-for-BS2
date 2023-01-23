package game.cfg
{
   import engine.automator.IClicker;
   import engine.core.logging.ILogger;
   import engine.gui.GuiUtil;
   import engine.gui.IGuiButton;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import game.gui.IGuiDevPanel;
   
   public class GameAutomatedProgramClicker implements IClicker
   {
       
      
      private var config:GameConfig;
      
      public var logger:ILogger;
      
      public function GameAutomatedProgramClicker(param1:GameConfig)
      {
         super();
         this.config = param1;
         this.logger = param1.logger;
      }
      
      public function performClick(param1:String) : Boolean
      {
         var _loc2_:IGuiButton = this._searchForButton(param1,this.config.pageManager.holder);
         if(_loc2_)
         {
            this.logger.i("AUTO","CLICKING GUI " + GuiUtil.getFullPath(_loc2_.movieClip));
            _loc2_.press();
            return true;
         }
         return false;
      }
      
      private function _searchForButton(param1:String, param2:DisplayObjectContainer) : IGuiButton
      {
         var _loc5_:DisplayObjectContainer = null;
         var _loc6_:int = 0;
         var _loc7_:DisplayObject = null;
         var _loc8_:IGuiButton = null;
         var _loc9_:DisplayObjectContainer = null;
         if(!param2 || !param1)
         {
            return null;
         }
         param1 = param1.toLowerCase();
         var _loc3_:Array = [param2];
         var _loc4_:int = 0;
         while(_loc3_.length)
         {
            _loc5_ = _loc3_.pop();
            if(_loc5_.visible)
            {
               if(!(!_loc5_.mouseChildren && !_loc5_.mouseEnabled))
               {
                  if(!(_loc5_ is IGuiDevPanel))
                  {
                     _loc4_++;
                     _loc6_ = 0;
                     while(_loc6_ < _loc5_.numChildren)
                     {
                        _loc7_ = _loc5_.getChildAt(_loc6_);
                        if(_loc7_.visible)
                        {
                           _loc8_ = this._buttonMatches(param1,_loc7_);
                           if(_loc8_)
                           {
                              return _loc8_;
                           }
                           _loc9_ = _loc7_ as DisplayObjectContainer;
                           if(_loc9_)
                           {
                              _loc3_.push(_loc9_);
                           }
                        }
                        _loc6_++;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      private function _buttonMatches(param1:String, param2:DisplayObject) : IGuiButton
      {
         var _loc6_:String = null;
         var _loc3_:IGuiButton = param2 as IGuiButton;
         if(!_loc3_)
         {
            return null;
         }
         if(!_loc3_.enabled)
         {
            return null;
         }
         if(param1.charAt(0) == "$")
         {
            _loc6_ = _loc3_.buttonToken;
            if(_loc6_)
            {
               _loc6_ = "$" + _loc6_.toLowerCase();
               if(param1 == _loc6_)
               {
                  return _loc3_;
               }
            }
         }
         var _loc4_:String = _loc3_.buttonText;
         if(_loc4_)
         {
            _loc4_ = _loc4_.toLowerCase();
            if(_loc4_ == param1)
            {
               return _loc3_;
            }
         }
         var _loc5_:String = _loc3_.movieClip.name;
         if(_loc5_)
         {
            _loc5_ = _loc5_.toLowerCase();
            if(_loc5_ == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
   }
}
