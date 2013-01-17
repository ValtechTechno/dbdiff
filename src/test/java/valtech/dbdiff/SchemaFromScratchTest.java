package valtech.dbdiff;

import static org.fest.assertions.api.Assertions.assertThat;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import javax.persistence.Entity;

import org.hibernate.cfg.Configuration;
import org.hibernate.dialect.Oracle10gDialect;
import org.hibernate.tool.hbm2ddl.SchemaExport;
import org.junit.Test;
import org.reflections.Reflections;
import org.reflections.scanners.TypeAnnotationsScanner;
import org.reflections.util.ClasspathHelper;
import org.reflections.util.ConfigurationBuilder;

import valtech.dbdiff.model.MyNamingStrategy;

public class SchemaFromScratchTest {

	public static final String ORACLE_DIALECT = Oracle10gDialect.class.getCanonicalName();
	public static final String CREATE_FILE_NAME = "./target/classes/sql/create_schema_from_scratch.sql";
	public static final String PACKAGE = "valtech.dbdiff.model";
	public static final int LAST_MODIFIED_PRECISION = 999;

	@Test
	public void generateCreate() throws ClassNotFoundException {
		final long now = System.currentTimeMillis() - LAST_MODIFIED_PRECISION;
		final Configuration cfg = new Configuration();
		cfg.setProperty("hibernate.hbm2ddl.auto", "create");
		cfg.setProperty("hibernate.dialect", ORACLE_DIALECT);
		cfg.setNamingStrategy(new MyNamingStrategy());

		for (final String className : findEntities()) {
			cfg.addAnnotatedClass(Class.forName(className));
		}

		final SchemaExport export = new SchemaExport(cfg);
		export.setDelimiter(";");
		export.setOutputFile(CREATE_FILE_NAME);
		export.execute(true, false, false, true);
		File file = new File(CREATE_FILE_NAME);
		assertThat(file.lastModified()).as("the file should be generated").isGreaterThan(now);
	}

	private List<String> findEntities() {
		final ConfigurationBuilder c = new ConfigurationBuilder();
		c.setUrls(ClasspathHelper.forPackage(PACKAGE));
		c.setScanners(new TypeAnnotationsScanner());
		final Reflections reflections = new Reflections(c);
		final Set<Class<?>> entities = reflections.getTypesAnnotatedWith(Entity.class);
		final List<String> entityClassNameList = new ArrayList<String>(entities.size());
		for (final Class<?> entity : entities) {
			entityClassNameList.add(entity.getName());
		}
		return entityClassNameList;
	}
}
