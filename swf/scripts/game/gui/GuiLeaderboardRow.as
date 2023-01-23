package game.gui
{
   import com.stoicstudio.platform.PlatformUserProfile;
   import engine.core.util.ColorUtil;
   import engine.gui.GuiButtonState;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class GuiLeaderboardRow extends ButtonWithIndex
   {
       
      
      public var rankText:TextField;
      
      public var scoreText:TextField;
      
      public var nameText:TextField;
      
      private var glowFilter:GlowFilter;
      
      private var existingFilters:Array;
      
      private var currentAccountId:String;
      
      public function GuiLeaderboardRow(param1:TextField, param2:TextField, param3:TextField)
      {
         this.glowFilter = new GlowFilter(10145518,1,6,6,2,1);
         this.existingFilters = new Array();
         super();
         this.rankText = param1;
         this.scoreText = param2;
         this.nameText = param3;
         this.existingFilters = param3.filters;
         enabled = PlatformUserProfile.isSupported;
      }
      
      private static function setTextField(param1:TextField, param2:String, param3:int) : void
      {
         var _loc4_:* = "<font color=\'" + ColorUtil.colorStr(param3) + "\'>" + param2 + "</font>";
         param1.htmlText = _loc4_;
      }
      
      public function showEntry(param1:Number, param2:int, param3:String, param4:Number, param5:String) : void
      {
         var _loc6_:Rectangle = null;
         this.visible = true;
         this.currentAccountId = param5 || param3;
         setTextField(this.rankText,param1.toString(),param2);
         setTextField(this.scoreText,param4.toString(),param2);
         setTextField(this.nameText,param3,param2);
         if(enabled)
         {
            _loc6_ = this.nameText.getRect(this.parent);
            graphics.clear();
            graphics.beginFill(0,0);
            graphics.drawRect(_loc6_.x,_loc6_.y,_loc6_.width,_loc6_.height);
         }
      }
      
      public function clear() : void
      {
         this.visible = false;
         this.currentAccountId = null;
      }
      
      override public function press() : void
      {
         if(Boolean(this.currentAccountId) && PlatformUserProfile.isSupported)
         {
            PlatformUserProfile.showUserProfile(this.currentAccountId);
         }
      }
      
      override public function set state(param1:GuiButtonState) : void
      {
         super.state = param1;
         if(this.nameText)
         {
            this.nameText.filters = isHovering ? this.existingFilters.concat(this.glowFilter) : this.existingFilters;
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         this.rankText.visible = this.scoreText.visible = this.nameText.visible = super.visible = param1;
      }
   }
}
