import java.text.NumberFormat;
import java.util.Map.Entry;
import java.util.SortedMap;
import java.util.TreeMap;

class MethodTimer {
  private class MethodTimingInfo {
    long    currentNanos;
    long    startTime;
    boolean isTiming;
  }

  private final double                              NANOS_TO_MILLIS = 1E-6;

  private final NumberFormat                        formatter       = NumberFormat.getNumberInstance();
  private final SortedMap<String, MethodTimingInfo> methodTimings   = new TreeMap<>();

  public MethodTimer() {
    formatter.setMinimumFractionDigits(1);
    formatter.setMaximumFractionDigits(3);
  }

  public void start() {
    String methodName = getCallingMethodName();
    MethodTimingInfo info = getValidInfo(methodName);
    if (info.isTiming) {
      System.err.println("Cannot re start timing the method: " + methodName);
    } else {
      info.isTiming = true;
      // set start time as late as possible
      info.startTime = System.nanoTime();
    }
  }

  public void stop() {
    // get stop time as early as possible
    long stopTime = System.nanoTime();
    String methodName = getCallingMethodName();
    MethodTimingInfo info = getValidInfo(methodName);
    if (!info.isTiming) {
      System.err.println("Cannot re stop timing the method: " + methodName);
    } else {
      info.isTiming = false;
      info.currentNanos += (stopTime - info.startTime);
    }
  }

  public void printAllTimings() {
    for (Entry<String, MethodTimingInfo> methodNameInfo : methodTimings.entrySet()) {
      String methodName = methodNameInfo.getKey();
      MethodTimingInfo info = methodNameInfo.getValue();
      System.out.println("Method: " + methodName + ' ' + formatter.format(info.currentNanos * NANOS_TO_MILLIS) + " ms");
    }
    System.out.println();
  }

  private String getCallingMethodName() {
    StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
    StackTraceElement callingTrace = stackTrace[3];
    return callingTrace.getMethodName();
  }

  private MethodTimingInfo getValidInfo(String methodName) {
    MethodTimingInfo info = methodTimings.get(methodName);
    if (info == null) {
      info = new MethodTimingInfo();
      methodTimings.put(methodName, info);
    }
    return info;
  }
}
