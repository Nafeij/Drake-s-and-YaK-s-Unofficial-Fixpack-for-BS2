package game.gui
{
   import com.greensock.TweenMax;
   import engine.gui.IGuiGpNavButton;
   import engine.saga.convo.def.ConvoOptionDef;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class GuiPoppeningChoice extends GuiBase implements IGuiGpNavButton
   {
      
      private static const FONT_SIZE:int = 30;
      
      private static const tf_normal:TextFormat = new TextFormat("Minion Pro",FONT_SIZE,16767921,false,false,false);
      
      private static const tf_hover:TextFormat = new TextFormat("Minion Pro",FONT_SIZE,16777215,false,false,true);
      
      private static const tf_clicked:TextFormat = new TextFormat("Minion Pro",FONT_SIZE,16777215,false,false,true);
      
      private static const tf_disabled:TextFormat = new TextFormat("Minion Pro",FONT_SIZE,11184810,false,false,false);
      
      private static const glow_normal:GlowFilter = new GlowFilter(0,1,6,6,2,3);
      
      private static const glow_hover:GlowFilter = new GlowFilter(40191,1,6,6,2,3);
      
      private static var TOKEN_REPLACE_ME:String = "__TOKEN_REPLACE_ME__";
       
      
      public var _text:TextField;
      
      public var callback:Function;
      
      public var opt:ConvoOptionDef;
      
      public var id:String;
      
      public var t:String;
      
      public var maxWidth:Number;
      
      public var base:GuiConvoBase;
      
      private var _selected:Boolean;
      
      private var _rolledOver:Boolean;
      
      private var _canGlow:Boolean = true;
      
      public function GuiPoppeningChoice()
      {
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiConvoBase) : void
      {
         this._text = requireGuiChild("text") as TextField;
         this._text.mouseEnabled = false;
         this.base = param2;
         super.initGuiBase(param1);
         this.visible = false;
      }
      
      public function setup(param1:String, param2:ConvoOptionDef, param3:String, param4:Function, param5:Number) : void
      {
         this.callback = param4;
         this.id = param1;
         this.opt = param2;
         if(!param3)
         {
            throw new ArgumentError("Need a string here");
         }
         this.t = param3;
         this.maxWidth = param5;
         this.visible = false;
         this.format(tf_normal,glow_normal);
         alpha = 1;
         this._selected = false;
         addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         addEventListener(MouseEvent.CLICK,this.clickHandler);
      }
      
      public function updateWidth(param1:Number) : void
      {
         this.maxWidth = param1;
         this.resetText();
      }
      
      private function resetText() : void
      {
         this._text.htmlText = TOKEN_REPLACE_ME;
         this._text.width = this.maxWidth;
         _context.locale.fixTextFieldFormat(this._text,null,null,false,this.base.textSizeModification);
         var _loc1_:String = this._text.htmlText;
         _loc1_ = _loc1_.replace(TOKEN_REPLACE_ME,!!this.t ? this.t : "");
         this._text.htmlText = _loc1_;
         this._text.width = Math.min(this._text.textWidth + 10,this.maxWidth);
         this._text.height = this._text.textHeight + 10;
      }
      
      private function format(param1:TextFormat, param2:GlowFilter) : void
      {
         this._text.defaultTextFormat = param1;
         this._text.setTextFormat(param1);
         this._text.filters = [param2];
         this.resetText();
      }
      
      public function disable() : void
      {
         TweenMax.to(this,0.2,{"alpha":0});
         this._rolledOver = false;
         mouseEnabled = false;
         mouseChildren = false;
         this.format(tf_disabled,glow_normal);
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         this.rolledOver = true;
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         this.rolledOver = false;
      }
      
      private function updateGlow() : void
      {
         if(this._rolledOver && this._canGlow)
         {
            this.format(tf_hover,glow_hover);
         }
         else
         {
            this.format(tf_normal,glow_normal);
         }
      }
      
      public function makeSelection() : void
      {
         this.format(tf_clicked,glow_hover);
         mouseEnabled = false;
         mouseChildren = false;
      }
      
      public function press() : void
      {
         if(this._selected)
         {
            return;
         }
         this._selected = true;
         context.playSound("ui_speech_bubble");
         this.makeSelection();
         this.callback(this);
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         this.press();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         mouseEnabled = param1;
         mouseChildren = false;
         if(!param1)
         {
            this.rolledOver = false;
         }
      }
      
      public function get canGlow() : Boolean
      {
         return this._canGlow;
      }
      
      public function set canGlow(param1:Boolean) : void
      {
         if(this._canGlow != param1)
         {
            this._canGlow = param1;
            this.updateGlow();
         }
      }
      
      public function get rolledOver() : Boolean
      {
         return this._rolledOver;
      }
      
      public function set rolledOver(param1:Boolean) : void
      {
         if(this._rolledOver == param1)
         {
            return;
         }
         this._rolledOver = param1;
         this.updateGlow();
      }
      
      public function setHovering(param1:Boolean) : void
      {
         this.rolledOver = param1;
      }
      
      override public function get enabled() : Boolean
      {
         return true;
      }
      
      public function getNavRectangle(param1:DisplayObject) : Rectangle
      {
         return this.getRect(param1);
      }
   }
}
