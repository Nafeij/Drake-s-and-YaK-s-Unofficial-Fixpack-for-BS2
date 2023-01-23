package game.gui
{
   import flash.display.DisplayObject;
   import flash.text.TextField;
   import game.saga.tally.ITallyStep;
   import game.saga.tally.TallyStep;
   
   public interface IGuiTallyTotal
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function cleanup() : void;
      
      function get value() : TextField;
      
      function initializeText(param1:String, param2:Number, param3:IGuiTransition) : void;
      
      function set numValue(param1:Number) : void;
      
      function get displayedValue() : int;
      
      function get displayObject() : DisplayObject;
      
      function animateToFinal(param1:int, param2:TallyStep, param3:DisplayObject, param4:Function = null, param5:int = 500) : void;
      
      function animateToTallyPoint(param1:TallyStep, param2:DisplayObject, param3:Function, param4:int = 300) : void;
      
      function animateToSum(param1:TallyStep, param2:IGuiTransition, param3:Function) : void;
      
      function snapToFinalPoint(param1:int, param2:TallyStep, param3:DisplayObject) : void;
      
      function updateNumValue(param1:Number) : void;
      
      function pulseValue(param1:Boolean) : void;
      
      function setValueToDays(param1:Number) : void;
      
      function initTallyTextWidth(param1:Vector.<ITallyStep>) : Number;
      
      function set textXOffset(param1:Number) : void;
      
      function get textXOffset() : Number;
      
      function setSumStepOffset() : void;
      
      function update(param1:int) : void;
      
      function get displayHours() : Boolean;
      
      function set displayHours(param1:Boolean) : void;
   }
}
