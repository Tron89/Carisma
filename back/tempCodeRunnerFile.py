engine = create_engine(
    DATABASE_URL,
    echo=True, # set to True to see SQL logs
    pool_pre_ping=True,
)