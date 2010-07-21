package gherkin.formatter.model;

public class Tag extends Mappable {
    private final String name;
    private final int line;

    public Tag(String name, int line) {
        this.name = name;
        this.line = line;
    }

    public String getName() {
        return name;
    }

    public int getLine() {
        return line;
    }
}
