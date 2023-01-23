package game.gui.travel
{
   import engine.math.MathUtil;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.GuiBase;
   
   public class GuiTravelBanner extends GuiBase
   {
       
      
      public var _text:TextField;
      
      public var _slider:MovieClip;
      
      public var _tooltip:TextField;
      
      public var travel:GuiTravelTop;
      
      public var varname:String;
      
      public var bag:IVariableBag;
      
      public var sliderMaxX:Number;
      
      public var sliderMinX:Number;
      
      private var _value:int = -9999;
      
      public var maxValue:int = 0;
      
      public var minValue:int = 0;
      
      public function GuiTravelBanner()
      {
         super();
      }
      
      public function init(param1:GuiBaseTravelTop, param2:IVariableBag, param3:String) : void
      {
         super.initGuiBase(param1.context);
         this.varname = param3;
         this.bag = param2;
         this._text = requireGuiChild("text") as TextField;
         this._slider = requireGuiChild("slider") as MovieClip;
         this._tooltip = requireGuiChild("tooltip") as TextField;
         this._text.mouseEnabled = false;
         mouseEnabled = true;
         mouseChildren = false;
         this._tooltip.mouseEnabled = false;
         this._tooltip.visible = false;
         this._tooltip.htmlText = context.translate(param3);
         this.addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         this.addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         this.sliderMaxX = this._slider.x;
         this.sliderMinX = this._text.x;
         _context.logger.info("SLIDER MINMAX " + param3 + " " + this.sliderMinX + " / " + this.sliderMaxX);
         var _loc4_:IVariable = param2.fetch(param3,null);
         if(!_loc4_)
         {
            context.logger.error("GuiTravelBanner Variable requirement missing: [" + param3 + "]");
            return;
         }
         this.minValue = _loc4_.def.lowerBound;
         this.maxValue = _loc4_.def.upperBound;
         param2.addEventListener(VariableEvent.TYPE,this.variableHandler);
         this.variableHandler(null);
         registerScalableTextfield(this._tooltip);
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         this._tooltip.htmlText = context.translate(this.varname);
         _context.currentLocale.fixTextFieldFormat(this._tooltip);
         scaleTextfields();
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         this.setHovering(false);
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         this.setHovering(true);
      }
      
      public function setHovering(param1:Boolean) : void
      {
         this._tooltip.visible = param1;
      }
      
      private function variableHandler(param1:VariableEvent) : void
      {
         var _loc2_:IVariable = null;
         var _loc3_:int = 0;
         if(!param1 || param1.value.def.name == this.varname)
         {
            _loc2_ = this.bag.fetch(this.varname,null);
            _loc3_ = !!_loc2_ ? _loc2_.asInteger : 0;
            this.value = _loc3_;
         }
      }
      
      public function cleanup() : void
      {
         this.removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         this.removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
         if(this.bag)
         {
            this.bag.removeEventListener(VariableEvent.TYPE,this.variableHandler);
            this.bag = null;
         }
         this.varname = null;
         super.cleanupGuiBase();
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function set value(param1:int) : void
      {
         if(this._value == param1)
         {
            return;
         }
         this._value = param1;
         this._text.text = this._value.toString();
         var _loc2_:Number = (this._value - this.minValue) / (this.maxValue - this.minValue);
         _loc2_ = MathUtil.clampValue(_loc2_,0,1);
         var _loc3_:Number = MathUtil.lerp(this.sliderMinX,this.sliderMaxX,_loc2_);
         _context.logger.info("SLIDER VALUE " + this.varname + " " + _loc3_ + " @" + _loc2_);
         this._slider.x = _loc3_;
      }
   }
}
