package com.sociodox.theminer.manager
{
   import com.sociodox.theminer.ui.ToolTip;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SkinManager
   {
      
      public static var mBitmapClass:skin_default;
      
      public static var mSkinBitmap:Bitmap;
      
      public static var mMonsterBitmap:Bitmap;
      
      public static var mDonateBitmap:Bitmap;
      
      public static var mSkinBitmapData:BitmapData;
      
      public static var mDefaultSkinBitmapData:BitmapData;
      
      public static var COLOR_GLOBAL_BG:uint = 0;
      
      public static var COLOR_GLOBAL_LINE:uint = 0;
      
      public static var COLOR_GLOBAL_LINE_DARK:uint = 0;
      
      public static var COLOR_GLOBAL_TEXT:uint = 0;
      
      public static var COLOR_GLOBAL_TEXT_GLOW:uint = 0;
      
      public static var COLOR_LIFLECYCLE_CREATE:uint = 0;
      
      public static var COLOR_LIFLECYCLE_REUSE:uint = 0;
      
      public static var COLOR_LIFLECYCLE_REMOVED:uint = 0;
      
      public static var COLOR_LIFLECYCLE_GC:uint = 0;
      
      public static var COLOR_STATS_BG:uint = 0;
      
      public static var COLOR_STATS_CURRENT:uint = 0;
      
      public static var COLOR_MOUSE_MOVE:uint = 0;
      
      public static var COLOR_MOUSE_CLICK:uint = 0;
      
      public static var COLOR_MOUSE_ENABLED:uint = 0;
      
      public static var COLOR_OVERDRAW:uint = 0;
      
      public static var COLOR_OVERDRAW_NOTVISIBLE:uint = 0;
      
      public static var COLOR_LOADER_SWF:uint = 0;
      
      public static var COLOR_LOADER_DISPLAYLOADER_COMPLETED:uint = 0;
      
      public static var COLOR_LOADER_URLSTREAM_COMPLETED:uint = 0;
      
      public static var COLOR_LOADER_URLLOADER_COMPLETED:uint = 0;
      
      public static var COLOR_LOADER_FALIED:uint = 0;
      
      public static var COLOR_LOADER_PROGRESS:uint = 0;
      
      public static var COLOR_INTERNAL_ENTERFRAME:uint = 0;
      
      public static var COLOR_INTERNAL_TIMER:uint = 0;
      
      public static var COLOR_INTERNAL_VERIFY:uint = 0;
      
      public static var COLOR_INTERNAL_REAP:uint = 0;
      
      public static var COLOR_INTERNAL_MARK:uint = 0;
      
      public static var COLOR_INTERNAL_SWEEP:uint = 0;
      
      public static var COLOR_INTERNAL_PRERENDER:uint = 0;
      
      public static var COLOR_INTERNAL_RENDER:uint = 0;
      
      public static var COLOR_INTERNAL_AVM1:uint = 0;
      
      public static var COLOR_INTERNAL_IO:uint = 0;
      
      public static var COLOR_INTERNAL_MOUSE:uint = 0;
      
      public static var COLOR_INTERNAL_FREE:uint = 0;
      
      public static var COLOR_SELECTION_OVERLAY:uint = 0;
      
      public static var IMAGE_OPTIONS_MONSTERS:Sprite = new Sprite();
      
      public static var IMAGE_OPTIONS_MONSTERS_DISABLED:Rectangle = new Rectangle(55,139,45,16);
      
      public static var IMAGE_OPTIONS_MONSTERS_ACTIVE:Rectangle = new Rectangle(55,160,45,16);
      
      public static var mDebugGraphScrollRect:Rectangle = new Rectangle(51,3,128,128);
       
      
      public function SkinManager()
      {
         super();
      }
      
      public static function LoadColors() : void
      {
         if(mSkinBitmapData == null)
         {
            mSkinBitmap = new Bitmap(new skin_default());
            mSkinBitmapData = mSkinBitmap.bitmapData;
            mMonsterBitmap = new Bitmap();
            mDonateBitmap = new Bitmap();
            mMonsterBitmap.bitmapData = mSkinBitmapData;
            mDonateBitmap.bitmapData = mSkinBitmapData;
            IMAGE_OPTIONS_MONSTERS.addChild(mMonsterBitmap);
         }
         COLOR_LOADER_PROGRESS = 4282663747;
         COLOR_INTERNAL_ENTERFRAME = 4289518286;
         COLOR_INTERNAL_TIMER = 4280241809;
         COLOR_SELECTION_OVERLAY = 4294962047;
         COLOR_INTERNAL_VERIFY = 4278255615;
         COLOR_GLOBAL_LINE_DARK = 4294769914;
         COLOR_INTERNAL_REAP = 4282724354;
         COLOR_INTERNAL_MARK = 4294833938;
         COLOR_INTERNAL_SWEEP = 4294115584;
         COLOR_INTERNAL_PRERENDER = 4286272171;
         COLOR_INTERNAL_RENDER = 4278242417;
         COLOR_STATS_CURRENT = 4278190335;
         COLOR_INTERNAL_IO = 4279299840;
         COLOR_INTERNAL_MOUSE = 4294901976;
         COLOR_INTERNAL_AVM1 = 4285560595;
         COLOR_LOADER_SWF = 4280435933;
         COLOR_LOADER_DISPLAYLOADER_COMPLETED = 4286033180;
         COLOR_INTERNAL_FREE = 4294967295;
         COLOR_LOADER_FALIED = 4289666605;
         COLOR_GLOBAL_TEXT = 4293980400;
         COLOR_STATS_BG = 4287006342;
         COLOR_GLOBAL_TEXT_GLOW = 4281545523;
         COLOR_LIFLECYCLE_CREATE = 4294090501;
         COLOR_LIFLECYCLE_REUSE = 4293729347;
         COLOR_GLOBAL_LINE = 4288190099;
         COLOR_LIFLECYCLE_REMOVED = 4284785910;
         COLOR_LIFLECYCLE_GC = 4289855377;
         COLOR_OVERDRAW_NOTVISIBLE = 4294793216;
         COLOR_MOUSE_MOVE = 4289855377;
         COLOR_MOUSE_CLICK = 4294090501;
         COLOR_MOUSE_ENABLED = 4289576918;
         COLOR_LOADER_URLLOADER_COMPLETED = 4291090413;
         COLOR_GLOBAL_BG = 4278190080;
         COLOR_OVERDRAW = 4293980400;
         COLOR_LOADER_URLSTREAM_COMPLETED = 4292453302;
      }
      
      public static function SetSkin(param1:BitmapData) : void
      {
         if(mDefaultSkinBitmapData == null)
         {
            mDefaultSkinBitmapData = new BitmapData(mSkinBitmapData.width,mSkinBitmapData.height,true);
            mDefaultSkinBitmapData.copyPixels(mSkinBitmapData,mSkinBitmapData.rect,new Point());
         }
         mSkinBitmapData.copyPixels(param1,param1.rect,new Point());
         LoadColors();
         ToolTip.UpdateSkin();
         OptionInterface.UpdateSkin();
         trace("Skin updated");
      }
      
      public static function SetDefaultSkin() : void
      {
         if(mDefaultSkinBitmapData == null)
         {
            return;
         }
         mSkinBitmapData.copyPixels(mDefaultSkinBitmapData,mDefaultSkinBitmapData.rect,new Point());
         LoadColors();
         ToolTip.UpdateSkin();
         OptionInterface.UpdateSkin();
         trace("Skin updated");
      }
   }
}
