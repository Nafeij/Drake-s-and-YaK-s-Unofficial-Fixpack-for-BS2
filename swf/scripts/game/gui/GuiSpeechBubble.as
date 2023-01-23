package game.gui
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.gui.IGuiSpeechBubble;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiSpeechBubble extends GuiBase implements IGuiSpeechBubble
   {
      
      private static var speech_bubble_num:int = 0;
       
      
      public var _text_small:TextField;
      
      public var _text_med:TextField;
      
      public var _text_large:TextField;
      
      public var _icon:GuiCharacterIconSlot;
      
      public var _small:MovieClip;
      
      public var _med:MovieClip;
      
      public var _large:MovieClip;
      
      private var _notranslate:Boolean;
      
      public function GuiSpeechBubble()
      {
         super();
         this.mouseEnabled = false;
         this.mouseChildren = false;
      }
      
      public function cleanup() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._icon.cleanup();
         this._icon = null;
         this._text_small = null;
         this._text_med = null;
         this._text_large = null;
         super.cleanupGuiBase();
      }
      
      private function checkTextFit(param1:TextField, param2:String) : Boolean
      {
         param1.htmlText = param2;
         if(!this._notranslate)
         {
            _context.locale.fixTextFieldFormat(param1);
         }
         if(param1.height >= param1.textHeight)
         {
            return true;
         }
         return false;
      }
      
      private function chooseText(param1:String) : TextField
      {
         if(!param1)
         {
            return null;
         }
         if(this.checkTextFit(this._text_small,param1))
         {
            return this._text_small;
         }
         if(this.checkTextFit(this._text_med,param1))
         {
            return this._text_med;
         }
         if(!this.checkTextFit(this._text_large,param1))
         {
            _context.logger.info("Speech bubble text is too large for speech bubble: [" + param1.substring(0,24) + "...]");
         }
         return this._text_large;
      }
      
      private function displayField(param1:TextField) : void
      {
         this._text_small.visible = this._small.visible = param1 == this._text_small;
         this._text_med.visible = this._med.visible = param1 == this._text_med;
         this._text_large.visible = this._large.visible = param1 == this._text_large;
         var _loc2_:Number = (param1.height - param1.textHeight) / 2;
         _loc2_ = Math.max(0,_loc2_);
         param1.y += _loc2_;
      }
      
      private function moveFieldToOrigin(param1:TextField) : void
      {
         if(param1 == this._text_small)
         {
            this.moveFieldAndBackToOrigin(this._text_small,this._small);
         }
         else if(param1 == this._text_med)
         {
            this.moveFieldAndBackToOrigin(this._text_med,this._med);
         }
         else if(param1 == this._text_large)
         {
            this.moveFieldAndBackToOrigin(this._text_large,this._large);
         }
      }
      
      private function moveFieldAndBackToOrigin(param1:TextField, param2:MovieClip) : void
      {
         param1.x -= param2.x;
         param1.y -= param2.y;
         param2.x = 0;
         param2.y = 0;
      }
      
      public function init(param1:*, param2:IBattleEntity, param3:IEntityDef, param4:String, param5:Number, param6:Boolean) : void
      {
         var _loc7_:IGuiContext = null;
         _loc7_ = param1;
         super.initGuiBase(_loc7_);
         this._notranslate = param6;
         this._text_small = requireGuiChild("text_small") as TextField;
         this._text_med = requireGuiChild("text_med") as TextField;
         this._text_large = requireGuiChild("text_large") as TextField;
         this._icon = requireGuiChild("icon") as GuiCharacterIconSlot;
         this._small = requireGuiChild("small") as MovieClip;
         this._med = requireGuiChild("med") as MovieClip;
         this._large = requireGuiChild("large") as MovieClip;
         this.cacheAsBitmap = true;
         _loc7_.playSound("ui_speech_bubble");
         name = "speech_bubble_" + ++speech_bubble_num;
         var _loc8_:TextField = this.chooseText(param4);
         this.displayField(_loc8_);
         this._icon.init(_loc7_);
         this._icon.setCharacter(param3,EntityIconType.ROSTER);
         if(this._icon.icon)
         {
            this._icon.icon.layout = GuiIconLayoutType.STRETCH;
         }
         this._icon.enabled = false;
         this._icon.visible = param3 != null;
         if(!this._icon.visible)
         {
            this.moveFieldToOrigin(_loc8_);
         }
      }
   }
}
