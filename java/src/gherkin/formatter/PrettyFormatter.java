package gherkin.formatter;

import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.Pattern;

import static gherkin.formatter.Colors.*;

public class PrettyFormatter implements Formatter {
    private final PrintWriter out;
    private final boolean monochrome;
    private int maxStepLength = 0;
    private int[] stepLengths;
    private int stepIndex;
    private List<List<String>> rows;

    public PrettyFormatter(OutputStream out, boolean monochrome) {
        this.out = new PrintWriter(out);
        this.monochrome = monochrome;
    }

    public void tag(String name, int line) {
        out.println(name);
    }

    public void comment(String content, int line) {
        out.println(content);
    }

    public void feature(String keyword, String name, int line) {
        out.println(keyword + ": " + indent(name, "  "));
        out.flush();
    }

    public void background(String keyword, String name, int line) {
        out.println("\n  " + keyword + ": " + name);
    }

    public void scenario(String keyword, String name, int line) {
        scenario(keyword, name, line, null);
    }

    public void scenario(String keyword, String name, int line, String location) {
        flushTable();
        out.println("\n  " + keyword + ": " + indent(name, "    ") + indentedScenarioLocation(keyword, name, location));
        out.flush();
    }

    public void scenario_outline(String keyword, String name, int line) {
        out.println("\n  " + keyword + ": " + name);
    }

    public void examples(String keyword, String name, int line) {
        flushTable();
        out.println("\n    " + keyword + ": " + name);
    }

    public void step(String keyword, String name, int line, String status, List<Argument> arguments, String location) {
        flushTable();
        out.println("    " + keyword + indent(name, "    ") + indentedStepLocation(keyword, name, location));
        out.flush();
    }

    public void flushTable() {
        if(rows == null) return;
        int columnCount = rows.get(0).size();
        int[][] cellLengths = new int[rows.size()][columnCount];
        int[] maxLengths = new int[columnCount];
        for(int i = 0; i < rows.size(); i++) {
            for(int j = 0; j < columnCount; j++) {
                int length = rows.get(i).get(j).length();
                cellLengths[i][j] = length;
                maxLengths[j] = Math.max(maxLengths[j], length);
            }
        }

        for(int i = 0; i < rows.size(); i++) {
            out.write("      | ");
            for(int j = 0; j < columnCount; j++) {
                out.write(rows.get(i).get(j));
                padSpace(maxLengths[j] - cellLengths[i][j]);
                if(j < columnCount -1) {
                    out.write(" | ");
                } else {
                    out.write(" |");
                }
            }
            out.println();
        }
        out.flush();
        rows = null;
    }

    public void step(String keyword, String name, int line) {
        step(keyword, name, line, null, Collections.<Argument>emptyList(), null);
    }

    public void row(List<String> row, int line) {
        if (rows == null) rows = new ArrayList<List<String>>();
        rows.add(row);
    }

    public void py_string(String string, int line) {
        out.println("      \"\"\"");
        out.print(Pattern.compile("^", Pattern.MULTILINE).matcher(string).replaceAll("      "));
        out.println("\n      \"\"\"");
    }

    public void eof() {
        flushTable();
        out.flush();
    }

    public void syntax_error(String state, String event, List<String> legalEvents, int line) {
        out.println("Syntax error:" + state + ' ' + event);
    }

    public void steps(List<List<String>> steps) {
        stepLengths = new int[steps.size()];
        int i = 0;
        for (List<String> step : steps) {
            int stepLength = step.get(0).length() + step.get(1).length();
            stepLengths[i++] = stepLength;
            maxStepLength = Math.max(maxStepLength, stepLength);
        }
        stepIndex = -1;
    }

    private void padSpace(int indent, StringBuffer buffer) {
        for (int i = 0; i < indent; i++) {
            buffer.append(" ");
        }
    }

    private void padSpace(int indent) {
        for (int i = 0; i < indent; i++) {
            out.write(" ");
        }
    }

    private String indent(String name, String indentation) {
        String indent = "";
        StringBuilder sb = new StringBuilder();
        String[] lines = name.split("\\n");
        for (int i = 0; i < lines.length; i++) {
            sb.append(indent).append(lines[i]);
            if (i < lines.length - 1) {
                sb.append("\n");
            }
            indent = indentation;
        }
        return sb.toString();
    }

    private String indentedScenarioLocation(String keyword, String name, String location) {
        if (location == null || "".equals(location)) return "";
        int l = keyword.length() + name.length();
        maxStepLength = Math.max(maxStepLength, l);
        int indent = maxStepLength - l;

        StringBuffer buffer = new StringBuffer();
        padSpace(indent, buffer);
        buffer.append(" ").append(comments("# " + location, monochrome));
        return buffer.toString();
    }

    private String indentedStepLocation(String keyword, String name, String location) {
        if (location == null || "".equals(location)) return "";
        int indent = maxStepLength - stepLengths[stepIndex += 1];

        StringBuffer buffer = new StringBuffer();
        padSpace(indent, buffer);
        buffer.append(" ").append(comments("# " + location, monochrome));
        return buffer.toString();
    }
}
