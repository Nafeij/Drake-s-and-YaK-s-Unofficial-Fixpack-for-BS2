package engine.core.util
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.IEventDispatcher;
   
   public interface INativeText extends IEventDispatcher
   {
       
      
      function set borderThickness(param1:uint) : void;
      
      function get borderThickness() : uint;
      
      function set borderColor(param1:uint) : void;
      
      function get borderColor() : uint;
      
      function set borderCornerSize(param1:uint) : void;
      
      function get borderCornerSize() : uint;
      
      function set autoCapitalize(param1:String) : void;
      
      function set autoCorrect(param1:Boolean) : void;
      
      function set color(param1:uint) : void;
      
      function set displayAsPassword(param1:Boolean) : void;
      
      function set editable(param1:Boolean) : void;
      
      function set fontFamily(param1:String) : void;
      
      function set fontPosture(param1:String) : void;
      
      function set fontSize(param1:uint) : void;
      
      function set fontWeight(param1:String) : void;
      
      function set locale(param1:String) : void;
      
      function set maxChars(param1:int) : void;
      
      function set restrict(param1:String) : void;
      
      function set returnKeyLabel(param1:String) : void;
      
      function get selectionActiveIndex() : int;
      
      function get selectionAnchorIndex() : int;
      
      function set softKeyboardType(param1:String) : void;
      
      function set text(param1:String) : void;
      
      function get text() : String;
      
      function set textAlign(param1:String) : void;
      
      function set visible(param1:Boolean) : void;
      
      function get multiline() : Boolean;
      
      function assignFocus() : void;
      
      function selectRange(param1:int, param2:int) : void;
      
      function set width(param1:Number) : void;
      
      function get width() : Number;
      
      function set height(param1:Number) : void;
      
      function get height() : Number;
      
      function set x(param1:Number) : void;
      
      function set y(param1:Number) : void;
      
      function get x() : Number;
      
      function get y() : Number;
      
      function set name(param1:String) : void;
      
      function get display() : DisplayObject;
      
      function set stage(param1:Stage) : void;
   }
}
