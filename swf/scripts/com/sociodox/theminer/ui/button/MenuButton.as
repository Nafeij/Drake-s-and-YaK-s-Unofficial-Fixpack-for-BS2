package com.sociodox.theminer.ui.button
{
   import com.sociodox.theminer.TheMiner;
   import com.sociodox.theminer.TheMinerActionEnum;
   import com.sociodox.theminer.data.InternalEventEntry;
   import com.sociodox.theminer.data.LoaderData;
   import com.sociodox.theminer.data.UserEventEntry;
   import com.sociodox.theminer.event.ChangeToolEvent;
   import com.sociodox.theminer.manager.Commands;
   import com.sociodox.theminer.manager.OptionInterface;
   import com.sociodox.theminer.manager.SkinManager;
   import com.sociodox.theminer.ui.ToolTip;
   import com.sociodox.theminer.window.Configuration;
   import com.sociodox.theminer.window.LoaderProfiler;
   import com.sociodox.theminer.window.PerformanceProfiler;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   
   public class MenuButton extends Sprite
   {
      
      public static const ICON_CAMERA:int = 12 * 0;
      
      public static const ICON_HELP:int = 12 * 1;
      
      public static const ICON_ARROW_DOWN:int = 12 * 2;
      
      public static const ICON_ARROW_UP:int = 12 * 3;
      
      public static const ICON_EVENTS:int = 12 * 4;
      
      public static const ICON_LIFE_CYCLE:int = 12 * 5;
      
      public static const ICON_MOUSE:int = 12 * 6;
      
      public static const ICON_OVERDRAW:int = 12 * 7;
      
      public static const ICON_STATS:int = 12 * 8;
      
      public static const ICON_MINIMIZE:int = 12 * 9;
      
      public static const ICON_CONFIG:int = 12 * 10;
      
      public static const ICON_CLIPBOARD:int = 12 * 11;
      
      public static const ICON_SOCKET:int = 12 * 12;
      
      public static const ICON_MONSTER:int = 12 * 13;
      
      public static const ICON_LOADER:int = 12 * 14;
      
      public static const ICON_CLEAR:int = 12 * 15;
      
      public static const ICON_STACK:int = 12 * 16;
      
      public static const ICON_PERFORMANCE:int = 12 * 17;
      
      public static const ICON_GC:int = 12 * 18;
      
      public static const ICON_MEMORY:int = 12 * 19;
      
      public static const ICON_SAVEDISK:int = 12 * 20;
      
      public static const ICON_PROMPT:int = 12 * 21;
      
      public static const ICON_LINK:int = 12 * 22;
      
      public static const ICON_GRADIENT:int = 12 * 23;
      
      public static const ICON_STAR:int = 12 * 24;
      
      public static const ICON_LOG:int = 12 * 25;
      
      public static const ICON_MAGNIFY:int = 12 * 26;
      
      public static const ICON_CUBE:int = 12 * 27;
      
      public static const ICON_ATTACH:int = 12 * 28;
      
      public static const ICON_FLOPPY:int = 12 * 29;
      
      public static const ICON_PAUSE:int = 12 * 30;
      
      public static const ICON_SKIN:int = 12 * 31;
      
      public static const ICON_FILTER:int = 12 * 32;
      
      public static const ICON_CLICK_AUDIO:int = 12 * 33;
      
      private static var mMinimizedScrollRect:Rectangle = new Rectangle(0,0,32,16);
       
      
      private var mBitmapViewport:Bitmap;
      
      private var mViewportRect:Rectangle;
      
      private var mIconOver:Bitmap;
      
      private var mIconSelected:Bitmap;
      
      private var mIconOut:Bitmap;
      
      public var mToolTipText:String;
      
      private var mToggleText:String;
      
      private var mToggleEventName:String;
      
      public var mIsSelected:Boolean = false;
      
      public var mAction:int = -1;
      
      private var mIsToggle:Boolean = true;
      
      public var mInternalEvent:InternalEventEntry = null;
      
      public var mUrl:String = null;
      
      public var mLD:LoaderData = null;
      
      public var mUserEvent:UserEventEntry = null;
      
      public var mUseListeners:Boolean = true;
      
      public function MenuButton(param1:int, param2:int, param3:int, param4:String, param5:int, param6:String, param7:Boolean = true, param8:String = null, param9:Boolean = true, param10:Boolean = true)
      {
         super();
         this.mBitmapViewport = new Bitmap(SkinManager.mSkinBitmapData);
         this.mViewportRect = new Rectangle(12,param3,12,12);
         this.mBitmapViewport.scrollRect = this.mViewportRect;
         this.addChild(this.mBitmapViewport);
         this.mToggleText = param8;
         this.mIsToggle = param7;
         this.mAction = param5;
         this.mouseChildren = false;
         this.mToggleEventName = param4;
         this.mToolTipText = param6;
         x = param1;
         y = param2;
         this.mUseListeners = param9;
         if(param9)
         {
            if(param10)
            {
               addEventListener(MouseEvent.MOUSE_MOVE,this.OnMouseMove,false,0,true);
               addEventListener(MouseEvent.MOUSE_OVER,this.OnMouseOver,false,0,true);
               addEventListener(MouseEvent.MOUSE_OUT,this.OnMouseOut,false,0,true);
            }
            addEventListener(MouseEvent.CLICK,this.OnClick,false,0,true);
         }
         else if(param10)
         {
            if(param10)
            {
               addEventListener(MouseEvent.MOUSE_MOVE,this.OnMouseMove,false,0,true);
               addEventListener(MouseEvent.MOUSE_OVER,this.OnMouseOver,false,0,true);
               addEventListener(MouseEvent.MOUSE_OUT,this.OnMouseOut,false,0,true);
            }
         }
      }
      
      private function OnMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS)
         {
            _loc2_ = true;
         }
         else if(Commands.mIsCollectingSamplesData)
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            pauseSampling();
         }
         ToolTip.SetPosition(param1.stageX + 12,param1.stageY + 6);
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      public function ShowIcon(param1:int) : void
      {
         if(param1 >= 0 && param1 < 3)
         {
            this.mViewportRect.x = 12 * param1;
            this.mBitmapViewport.scrollRect = this.mViewportRect;
         }
      }
      
      public function OnClick(param1:MouseEvent) : void
      {
         var _loc3_:Event = null;
         var _loc4_:Event = null;
         var _loc5_:Event = null;
         var _loc6_:Event = null;
         var _loc7_:Event = null;
         var _loc8_:Event = null;
         var _loc9_:Event = null;
         var _loc2_:Boolean = false;
         if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS)
         {
            _loc2_ = true;
         }
         else if(Commands.mIsCollectingSamplesData)
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            pauseSampling();
         }
         if(param1 != null)
         {
            param1.stopPropagation();
            param1.stopImmediatePropagation();
         }
         this.mViewportRect.x = 0;
         this.mBitmapViewport.scrollRect = this.mViewportRect;
         if(this.mIsSelected)
         {
            this.mIsSelected = false;
            if(this.mToggleText != null)
            {
               this.SetToolTipText(this.mToolTipText);
            }
            if(this.mToggleEventName == Commands.SAVE_RECORDING_EVENT)
            {
               _loc3_ = new Event(Commands.SAVE_RECORDING_EVENT,true);
               dispatchEvent(_loc3_);
            }
            else if(this.mToggleEventName == Commands.SAVE_RECORDING_TRACE_EVENT)
            {
               _loc4_ = new Event(Commands.SAVE_RECORDING_TRACE_EVENT,true);
               dispatchEvent(_loc4_);
            }
            else if(this.mToggleEventName != Configuration.LOAD_SKIN_EVENT)
            {
               if(this.mToggleEventName != Commands.TOGGLE_MINIMIZE)
               {
                  if(this.mAction != -1)
                  {
                     TheMiner.Do(this.mAction);
                  }
               }
            }
            if(_loc2_)
            {
               startSampling();
            }
            return;
         }
         if(this.mIsToggle)
         {
            this.mIsSelected = true;
            if(this.mIsSelected && this.mToggleText != null)
            {
               ToolTip.Text = this.mToggleText;
            }
         }
         if(this.mToggleEventName != null)
         {
            if(this.mToggleEventName === ChangeToolEvent.CHANGE_TOOL_EVENT)
            {
               TheMiner.Do(this.mAction);
               OptionInterface.ResetMenu(this);
            }
            else if(this.mToggleEventName !== Commands.TOGGLE_QUIT)
            {
               if(this.mToggleEventName !== Commands.SAVE_RECORDING_EVENT)
               {
                  if(this.mToggleEventName !== Commands.SAVE_RECORDING_TRACE_EVENT)
                  {
                     if(this.mToggleEventName === Configuration.LOAD_SKIN_EVENT)
                     {
                        _loc5_ = new Event(Configuration.LOAD_SKIN_EVENT,true);
                        dispatchEvent(_loc5_);
                     }
                     else if(this.mToggleEventName === Commands.TOGGLE_MINIMIZE)
                     {
                        OptionInterface.ResetMenu(null);
                        OptionInterface.Hide();
                        TheMiner.Do(TheMinerActionEnum.CLOSE_PROFILERS);
                     }
                     else if(this.mToggleEventName === Commands.SAVE_SNAPSHOT_EVENT)
                     {
                        _loc6_ = new Event(Commands.SAVE_SNAPSHOT_EVENT,true);
                        dispatchEvent(_loc6_);
                     }
                     else if(this.mToggleEventName === PerformanceProfiler.SAVE_FUNCTION_STACK_EVENT)
                     {
                        _loc7_ = new Event(PerformanceProfiler.SAVE_FUNCTION_STACK_EVENT,true);
                        dispatchEvent(_loc7_);
                     }
                     else if(this.mToggleEventName === LoaderProfiler.SAVE_FILE_EVENT)
                     {
                        _loc8_ = new Event(LoaderProfiler.SAVE_FILE_EVENT,true);
                        dispatchEvent(_loc8_);
                     }
                     else if(this.mToggleEventName === LoaderProfiler.GO_TO_LINK)
                     {
                        _loc9_ = new Event(LoaderProfiler.GO_TO_LINK,true);
                        dispatchEvent(_loc9_);
                     }
                     else
                     {
                        if(this.mToggleEventName === Commands.SCREEN_CAPTURE_EVENT)
                        {
                           dispatchEvent(new Event(Commands.SCREEN_CAPTURE_EVENT,true));
                        }
                        TheMiner.Do();
                        OptionInterface.ResetMenu(null);
                     }
                  }
               }
            }
         }
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      public function OnMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS)
         {
            _loc2_ = true;
         }
         else if(Commands.mIsCollectingSamplesData)
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            pauseSampling();
         }
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         if(this.mViewportRect.x == 12 * 1)
         {
            this.mViewportRect.x = 12 * 2;
            this.mBitmapViewport.scrollRect = this.mViewportRect;
         }
         if(this.mIsSelected && this.mToggleText != null)
         {
            ToolTip.Text = this.mToggleText;
         }
         else
         {
            ToolTip.Text = this.mToolTipText;
         }
         ToolTip.Visible = true;
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      public function SetToolTipText(param1:String) : void
      {
         this.mToolTipText = param1;
         if(this.mViewportRect.x == 0)
         {
            ToolTip.Text = param1;
         }
      }
      
      public function OnMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS)
         {
            _loc2_ = true;
         }
         else if(Commands.mIsCollectingSamplesData)
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            pauseSampling();
         }
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         ToolTip.Visible = false;
         if(this.mIsSelected)
         {
            return;
         }
         this.mViewportRect.x = 12 * 1;
         this.mBitmapViewport.scrollRect = this.mViewportRect;
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      public function Reset() : void
      {
         this.mIsSelected = false;
         this.mViewportRect.x = 12 * 1;
         this.mBitmapViewport.scrollRect = this.mViewportRect;
      }
      
      public function Dispose() : void
      {
         if(this.mIconOver != null)
         {
            if(this.mIconOver.bitmapData != null)
            {
               this.mIconOver.bitmapData.dispose();
            }
            this.mIconOver = null;
         }
         if(this.mIconSelected != null)
         {
            if(this.mIconSelected.bitmapData != null)
            {
               this.mIconSelected.bitmapData.dispose();
            }
            this.mIconSelected = null;
         }
         if(this.mIconOut != null)
         {
            if(this.mIconOut.bitmapData != null)
            {
               this.mIconOut.bitmapData.dispose();
            }
            this.mIconOut = null;
         }
         this.mToolTipText = null;
         this.mToggleText = null;
         this.mToggleEventName = null;
         this.mUserEvent = null;
         this.mLD = null;
         this.mAction = -1;
         this.mInternalEvent = null;
         this.mUrl = null;
      }
   }
}
