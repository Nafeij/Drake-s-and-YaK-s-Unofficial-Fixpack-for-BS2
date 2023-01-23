package com.sociodox.theminer.data
{
   import com.sociodox.theminer.manager.Localization;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.utils.ByteArray;
   
   public class LoaderData
   {
      
      public static const DISPLAY_LOADER:int = 1;
      
      public static const URL_STREAM:int = 2;
      
      public static const URL_LOADER:int = 3;
      
      public static const SWF_LOADED:int = 4;
      
      public static const LOADER_STATUS_WAITING:String = Localization.Lbl_LD_Waiting;
      
      public static const LOADER_STATUS_COMPLETED:String = Localization.Lbl_LD_Completed;
      
      public static const LOADER_DEFAULT_URL:String = "-";
      
      public static const LOADER_DEFAULT_HTTP_STATUS:String = "-";
      
      public static const QUESTION_MARK:String = "?";
       
      
      public var mUrl:String = null;
      
      public var mType:int = 0;
      
      public var mFirstEvent:int = -1;
      
      public var mLastEvent:int = -1;
      
      public var mIOError:IOErrorEvent = null;
      
      public var mSecurityError:SecurityErrorEvent = null;
      
      public var mStatus:HTTPStatusEvent = null;
      
      public var mProgress:Number = 0;
      
      public var mProgressText:String = "?";
      
      public var mHTTPStatusText:String = null;
      
      public var mIsFinished:Boolean = false;
      
      public var mLoadedBytes:int = 0;
      
      public var mLoadedBytesText:String = "0";
      
      public var mLoadedData:ByteArray = null;
      
      public function LoaderData()
      {
         super();
      }
   }
}
