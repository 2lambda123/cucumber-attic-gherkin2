package gherkin.model;

import gherkin.formatter.Argument;
import gherkin.formatter.Formatter;

import java.util.*;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Step extends BasicStatement implements RowContainer {
    private Object multiline_arg;
    private final List<Integer> matched_columns;
    public Step next;

    public Step(List<Comment> comments, String keyword, String name, int line) {
        this(comments, keyword, name, line, null);
    }

    private Step(List<Comment> comments, String keyword, String name, int line, List<Integer> matchedColumns) {
        super(comments, keyword, name, line);
        matched_columns = matchedColumns;
    }

    @Override
    public Map<Object, Object> toMap() {
        Map<Object, Object> map = super.toMap();
        if (getRows() != null) {
            Map<Object, Object> multilineArg = new HashMap<Object, Object>();
            multilineArg.put("type", "table");
            multilineArg.put("value", map.get("multiline_arg"));
            map.put("multiline_arg", multilineArg);
        } else if (getPyString() != null) {
            ((Map<Object, Object>) map.get("multiline_arg")).put("type", "py_string");
        }
        return map;
    }

    @Override
    public Range getLineRange() {
        Range range = super.getLineRange();
        if (getRows() != null) {
            range = new Range(range.getFirst(), getRows().get(getRows().size() - 1).getLine());
        } else if (getPyString() != null) {
            range = new Range(range.getFirst(), getPyString().getLineRange().getLast());
        }
        return range;
    }

    @Override
    public void replay(Formatter formatter) {
        formatter.step(this);
    }

    public List<Argument> getOutlineArgs() {
        List<Argument> result = new ArrayList<Argument>();
        Pattern p = Pattern.compile("<[^<]*>");
        Matcher matcher = p.matcher(getName());
        while(matcher.find()) {
            MatchResult matchResult = matcher.toMatchResult();
            result.add(new Argument(matchResult.start(), matchResult.group()));
        }
        return result;
    }

    public Match getOutlineMatch(String location) {
        return new Match(getOutlineArgs(), location, null);
    }

    public void setMultilineArg(Object multilineArg) {
        this.multiline_arg = multilineArg;
    }

    public Object getMultilineArg() {
        return multiline_arg;
    }

    public List<Row> getRows() {
        return multiline_arg instanceof List ? (List<Row>) multiline_arg : null;
    }

    public PyString getPyString() {
        return multiline_arg instanceof PyString ? (PyString) multiline_arg : null;
    }

    public String toString() {
        return getKeyword() + getName();
    }

    public Step createExampleStep(Row headerRow, Row example) {
        List<Integer> matchedColumns = new ArrayList<Integer>();
        String name = getName();

        List<String> headerCells = headerRow.getCells();
        for (int i = 0; i < headerCells.size(); i++) {
            String headerCell = headerCells.get(i);
            String value = example.getCells().get(i);
            String token = "<" + headerCell + ">";
            if (name.contains(token)) {
                name = name.replace(token, value);
                matchedColumns.add(i);
            }
        }

        return new Step(getComments(), getKeyword(), name, getLine(), matchedColumns);
    }

    public List<Integer> getMatchedColumns() {
        return matched_columns;
    }

    public void addRow(Row row) {
        if(multiline_arg == null) {
            multiline_arg = new ArrayList<Row>();
        }
        getRows().add(row);
    }

    public StackTraceElement getStackTraceElement() {
        return new StackTraceElement("✽", getKeyword() + getName(), "fix/me/now.feature", getLine());
    }

    public void accept(Visitor v) {
        v.visitStep(this);
    }


    public void accept(NewVisitor v) {
        //To change body of created methods use File | Settings | File Templates.
    }
}
